from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str

    model_config = SettingsConfigDict(
        extra="ignore",
        env_prefix="APP_",
    )


settings = Settings()  # type: ignore[call-arg]
