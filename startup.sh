#!/bin/bash
set -e

echo "=== VibeCheck Startup Script ==="

# Create data directory
mkdir -p /app/data/images

# Download data files from Google Cloud Storage
echo "Downloading data from GCS bucket: vice-check-data..."

# Download output data files (vibecheck.db, faiss index, etc.)
echo "Downloading output data files..."
gsutil -m cp -r "gs://vice-check-data/ouput data files/*" /app/data/

# Download all image folders
echo "Downloading restaurant images..."
gsutil -m cp -r "gs://vice-check-data/images 2/*" /app/data/images/
gsutil -m cp -r "gs://vice-check-data/images 3/*" /app/data/images/
gsutil -m cp -r "gs://vice-check-data/images 4/*" /app/data/images/
gsutil -m cp -r "gs://vice-check-data/images 5/*" /app/data/images/

echo "Data download complete!"
echo "Data directory contents:"
ls -lh /app/data/ || echo "Data directory is empty"
echo "Images count:"
ls /app/data/images/ | wc -l

echo "=== Starting Flask App ==="
exec "$@"
