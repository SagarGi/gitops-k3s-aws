import os
from flask import Blueprint, jsonify

api_bp = Blueprint("api", __name__)
#this is just for change in the code and to push to check deployments
app_version = "v1.1.0"

@api_bp.route("/")
def index():
    return jsonify({
        "status": "online",
        "message": "GitOps Platform Running on K3s",
        "environment": os.getenv("ENVIRONMENT", "dev")
    }), 200

@api_bp.route("/healthz")
def health():
    """Liveness & Readiness probe for K3s / Kubernetes pods."""
    return jsonify({"status": "healthy"}), 200

@api_bp.route('/version', methods=['GET'])
def get_version():
    return jsonify(
        {
            "app_version" : app_version
        }
    ), 200