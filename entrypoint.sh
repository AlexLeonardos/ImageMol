#!/bin/bash

# Check if the bucket name is passed as the first argument
if [ -z "$1" ]; then
  echo "Error: Bucket name must be provided as the first argument."
  exit 1
fi

BUCKET_NAME=$1

# Mount the GCS bucket using gcsfuse
MOUNT_POINT=/mnt/gcs-bucket
mkdir -p "$MOUNT_POINT"
gcsfuse "$BUCKET_NAME" "$MOUNT_POINT"

# Echo the dataroot path for the user
echo "Bucket mounted at: $MOUNT_POINT"
echo "Use this path as the --dataroot argument when running finetune.py."