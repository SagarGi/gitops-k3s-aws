import os
from flask import Flask
from src.config import config_by_name

def create_app(config_name=None):
    if config_name is None:
        config_name = os.getenv("ENVIRONMENT", "dev")

    app = Flask(__name__)
    
    # Load configuration class
    app.config.from_object(config_by_name.get(config_name, config_by_name["default"]))

    # Register Blueprints
    from src.api.routes import api_bp
    app.register_blueprint(api_bp)

    return app