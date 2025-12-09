# VibeCheck Flask Application Dockerfile
# Optimized for production deployment with all models and dependencies

FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies including Google Cloud SDK
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    gnupg \
    lsb-release \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry for dependency management
RUN pip install --no-cache-dir poetry==1.7.1

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Configure poetry to not create virtual env (we're in container)
RUN poetry config virtualenvs.create false

# Install Python dependencies
# Install main dependencies + CLIP from git + production server
RUN poetry install --only main --no-interaction --no-ansi && \
    pip install --no-cache-dir git+https://github.com/openai/CLIP.git && \
    pip install --no-cache-dir gunicorn

# Copy application code
COPY app/app.py ./app.py
COPY app/templates/ ./templates/
COPY app/static/ ./static/
COPY src/ ./src/

# Copy startup script
COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh

# Set Python path
ENV PYTHONPATH=/app/src

# Environment variables for optimal performance
ENV OMP_NUM_THREADS=1
ENV MKL_NUM_THREADS=1
ENV FLASK_ENV=production

# Default paths (can be overridden in docker-compose)
ENV OUTPUT_DIR=/app/data
ENV DB_PATH=/app/data/vibecheck.db
ENV IMAGE_DIR=/app/data/images
ENV FAISS_PATH=/app/data/vibecheck_index.faiss
ENV META_PATH=/app/data/meta_ids.npy
ENV VIBE_MAP_CSV=/app/data/vibe_map.csv

# Expose Flask port
EXPOSE 8080

# Health check - longer start period for data download
HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Run startup script then Flask application with gunicorn
ENTRYPOINT ["/app/startup.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "4", "--timeout", "300", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
