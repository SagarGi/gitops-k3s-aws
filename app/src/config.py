import os

class Config:
    """Base configuration settings shared across environments."""
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-fallback-key-change-in-prod")
    JSON_SORT_KEYS = False

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False

# Mapping configuration targets
config_by_name = {
    "dev": DevelopmentConfig,
    "prod": ProductionConfig,
    "default": ProductionConfig
}