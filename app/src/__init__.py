import os
from flask import Flask
from src.config import config_by_name
from prometheus_flask_exporter import PrometheusMetrics

def create_app(config_name=None):
    if config_name is None:
        config_name = os.getenv("ENVIRONMENT", "dev")

    app = Flask(__name__)

    # Initialize Prometheus exporter with the Flask app instance
    metrics = PrometheusMetrics(app)
    metrics.info('app_info', 'Application info', version='1.0.0')
    
    # Load configuration class
    app.config.from_object(config_by_name.get(config_name, config_by_name["default"]))

    # Register Blueprints
    from src.api.routes import api_bp
    app.register_blueprint(api_bp)

    return app