import os
from flask import Blueprint, jsonify

api_bp = Blueprint("api", __name__)

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