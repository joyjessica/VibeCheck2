#!/bin/bash
set -x  # Enable command tracing
# Don't use set -e, we want to continue even if downloads fail

echo "=== VibeCheck Startup Script ==="
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo "PORT environment variable: ${PORT}"

# Create data directory
mkdir -p /app/data/images
echo "Created directories"

# Download data files from Google Cloud Storage
echo "Downloading data from GCS bucket: vice-check-data..."

# Download output data files (vibecheck.db, faiss index, etc.)
echo "Downloading output data files..."
gsutil -m cp -r "gs://vice-check-data/ouput data files/"* /app/data/ 2>&1 || {
    echo "Warning: Failed to download output data files"
    echo "Attempting alternative path..."
    gsutil -m cp "gs://vice-check-data/ouput data files/*" /app/data/ 2>&1 || echo "Alternative also failed"
}

# Download all image folders
echo "Downloading restaurant images..."
gsutil -m cp -r "gs://vice-check-data/images 2/"* /app/data/images/ 2>&1 || echo "Warning: Failed to download images 2"
gsutil -m cp -r "gs://vice-check-data/images 3/"* /app/data/images/ 2>&1 || echo "Warning: Failed to download images 3"
gsutil -m cp -r "gs://vice-check-data/images 4/"* /app/data/images/ 2>&1 || echo "Warning: Failed to download images 4"
gsutil -m cp -r "gs://vice-check-data/images 5/"* /app/data/images/ 2>&1 || echo "Warning: Failed to download images 5"

echo "Data download complete!"
echo "Data directory contents:"
ls -lh /app/data/ 2>&1 | head -20
echo "Images count:"
ls /app/data/images/ 2>/dev/null | wc -l || echo "0"

echo "=== Starting Flask App ==="
echo "Command: $@"
exec "$@"
