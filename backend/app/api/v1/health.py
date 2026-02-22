from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.schemas.health import StatusResponse

router = APIRouter(tags=["health"])


@router.get("/healthz", response_model=StatusResponse)
def healthz() -> StatusResponse:
    return StatusResponse(status="ok")


@router.get("/readyz", response_model=StatusResponse)
def readyz(db: Session = Depends(get_db)) -> StatusResponse:
    try:
        db.execute(text("SELECT 1"))
        return StatusResponse(status="ready")
    except SQLAlchemyError as e:
        raise HTTPException(status_code=503, detail="Database not reachable") from e
