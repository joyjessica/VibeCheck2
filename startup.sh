#!/bin/bash
# Don't use set -e or set -x to keep startup fast

echo "=== VibeCheck Startup Script ==="

# Create data directory
mkdir -p /app/data/images

# Start data download in background (don't block app startup)
(
    echo "Background: Starting data download from GCS..."

    # Download output data files
    gsutil -m cp -r "gs://vice-check-data/ouput data files/"* /app/data/ 2>&1 | head -20 || echo "Warning: Output data download failed"

    # Download images
    gsutil -m cp -r "gs://vice-check-data/images 2/"* /app/data/images/ 2>&1 | head -5 || true
    gsutil -m cp -r "gs://vice-check-data/images 3/"* /app/data/images/ 2>&1 | head -5 || true
    gsutil -m cp -r "gs://vice-check-data/images 4/"* /app/data/images/ 2>&1 | head -5 || true
    gsutil -m cp -r "gs://vice-check-data/images 5/"* /app/data/images/ 2>&1 | head -5 || true

    echo "Background: Data download complete! $(ls /app/data/images/ 2>/dev/null | wc -l) images downloaded"
) &

echo "Starting Flask app immediately (data downloads in background)..."
exec "$@"
