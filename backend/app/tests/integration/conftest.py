import time

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import Engine, text
from sqlalchemy.orm import Session, sessionmaker

from app.api.deps import get_db
from app.db.session import get_engine
from app.main import create_app


def _wait_for_db(engine: Engine, timeout_s: int = 30) -> None:
    deadline = time.time() + timeout_s
    last_err: Exception | None = None
    while time.time() < deadline:
        try:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            return
        except Exception as e:
            last_err = e
            time.sleep(1)
    raise RuntimeError(f"DB not ready after {timeout_s}s: {last_err}")


@pytest.fixture(scope="session")
def engine():
    eng = get_engine()
    _wait_for_db(eng)

    yield eng
    eng.dispose()


@pytest.fixture(scope="function")
def db_session(engine: Engine):
    """
    One real DB connection per test, wrapped in a transaction that rolls back.
    Keeps tests isolated.
    """
    connection = engine.connect()
    transaction = connection.begin()
    TestingSessionLocal = sessionmaker(bind=connection, autocommit=False, autoflush=False)
    session = TestingSessionLocal()

    try:
        yield session
    finally:
        session.close()
        transaction.rollback()
        connection.close()


@pytest.fixture(scope="function")
def client(db_session: Session):
    app = create_app()

    # Override get_db dependency to return the test session
    def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    with TestClient(app) as c:
        yield c

    app.dependency_overrides.clear()
