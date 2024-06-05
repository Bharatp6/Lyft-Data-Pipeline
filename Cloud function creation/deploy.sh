#!/bin/bash

# Set variables
GITHUB_REPO="https://github.com/Cloud-Function-Data-Ingest/"
PROJECT_ID="igj007"
FUNCTION_NAME="get_station_status"
REGION="us-central1"
RUNTIME="python39"
ENTRY_POINT="get_station_status"
TEMP_DIR="cloud_function_deploy"
KEY_FILE_PATH="https://raw.githubusercontent.com/Bharatp6/Lyft-Data-Pipeline/main/igj007-a263924715a0.json"

# Authenticate with Google Cloud using the service account
gcloud auth activate-service-account --key-file=$KEY_FILE_PATH
gcloud config set project $PROJECT_ID

# Clone the GitHub repository
git clone $GITHUB_REPO $TEMP_DIR

# Navigate to the function's directory
cd $TEMP_DIR

# Deploy the Cloud Function
gcloud functions deploy $FUNCTION_NAME \
  --runtime $RUNTIME \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point $ENTRY_POINT \
  --region $REGION \
  --source .

# Check if the deployment was successful
if [ $? -eq 0 ]; then
    echo "Cloud Function deployed successfully!"
    FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME --region $REGION --format 'value(httpsTrigger.url)')
    echo "Function URL: $FUNCTION_URL"
else
    echo "Failed to deploy Cloud Function."
fi

# Clean up
cd ..
rm -rf $TEMP_DIR
