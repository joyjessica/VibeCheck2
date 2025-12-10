#!/bin/bash
# Enable error reporting
set -e

echo "=== VibeCheck Startup Script ===" >&2

# Create data directory
echo "Creating data directories..." >&2
mkdir -p /app/data/images

# Start data download in background (don't block app startup)
(
    echo "Background: Starting data download from GCS..." >&2

    # Download output data files
    gsutil -m cp -r "gs://vice-check-data/output data files/"* /app/data/ 2>&1 | head -20 || echo "Warning: Output data download failed" >&2

    # Download images
    gsutil -m cp -r "gs://vice-check-data/images 2/"* /app/data/images/ 2>&1 | head -5 || true
    gsutil -m cp -r "gs://vice-check-data/images 3/"* /app/data/images/ 2>&1 | head -5 || true
    gsutil -m cp -r "gs://vice-check-data/images 4/"* /app/data/images/ 2>&1 | head -5 || true
    gsutil -m cp -r "gs://vice-check-data/images 5/"* /app/data/images/ 2>&1 | head -5 || true

    echo "Background: Data download complete! $(ls /app/data/images/ 2>/dev/null | wc -l) images downloaded" >&2
) &

echo "Starting Flask app immediately (data downloads in background)..." >&2
echo "About to exec: $@" >&2
exec "$@"
