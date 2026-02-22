import pytest
from pydantic import ValidationError

from app.core.config import Settings

APP_DATABASE_URL_ENV = "APP_DATABASE_URL"


def test_settings_loads_from_env(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv(APP_DATABASE_URL_ENV, "postgresql://user:pass@localhost:5432/regtrace")

    s = Settings()  # type: ignore[call-arg]

    assert str(s.database_url) == "postgresql://user:pass@localhost:5432/regtrace"


def test_settings_missing_required_values_raises(monkeypatch: pytest.MonkeyPatch) -> None:
    # Ensure required vars are absent
    monkeypatch.delenv(APP_DATABASE_URL_ENV, raising=False)

    with pytest.raises(ValidationError) as exc:
        Settings()  # type: ignore[call-arg]

    msg = str(exc.value)
    assert "database_url" in msg


def test_settings_rejects_invalid_database_url(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv(APP_DATABASE_URL_ENV, "invalid-url")

    with pytest.raises(ValidationError):
        Settings()  # type: ignore[call-arg]
