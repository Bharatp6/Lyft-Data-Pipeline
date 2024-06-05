#!/bin/bash

# Set variables
FUNCTION_NAME="fetch_station_status"
REGION="us-central1"
RUNTIME="python39"
ENTRY_POINT="get_station_status"
FUNCTION_DIR="Cloud-Function-Data-Ingest"  # The directory containing main.py and requirements.txt

# Authenticate with Google Cloud using the service account
gcloud auth activate-service-account --key-file=$KEY_FILE_PATH
gcloud config set project $PROJECT_ID

# Navigate to the function's directory
cd $FUNCTION_DIR

# Deploy the Cloud Function
gcloud functions deploy $FUNCTION_NAME \
  --runtime $RUNTIME \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point $ENTRY_POINT \
  --region $REGION

# Check if the deployment was successful
if [ $? -eq 0 ]; then
    echo "Cloud Function deployed successfully!"
    FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME --region $REGION --format 'value(httpsTrigger.url)')
    echo "Function URL: $FUNCTION_URL"
else
    echo "Failed to deploy Cloud Function."
fi
