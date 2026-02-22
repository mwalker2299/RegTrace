from fastapi import FastAPI

from app.api.v1.health import router as health_router
from app.api.v1.router import api_router


def create_app() -> FastAPI:
    app = FastAPI(title="RegTrace API")

    # root health endpoints (used for direct container health checks)
    app.include_router(health_router)

    # versioned API (health check available here too, which allows CI smoke test
    #                to confirm API is reachable via frontend proxy)
    app.include_router(api_router, prefix="/api/v1")
    return app


app = create_app()
