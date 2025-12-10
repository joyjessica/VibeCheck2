"""
WSGI entry point for gunicorn
"""
import os

# Set environment variables before importing app
os.environ.setdefault('FLASK_ENV', 'production')

# Import the Flask app
from app.app import app as application

# For local testing
if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    application.run(host="0.0.0.0", port=port)
