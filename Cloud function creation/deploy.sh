#!/bin/bash

# Ensure required environment variables are set
if [ -z "$PROJECT_ID" ] || [ -z "$GOOGLE_APPLICATION_CREDENTIALS_JSON" ]; then
  echo "Environment variables PROJECT_ID and GOOGLE_APPLICATION_CREDENTIALS_JSON must be set."
  exit 1
fi

# Create a temporary file for the key
KEY_FILE_PATH=$(mktemp)
echo "$GOOGLE_APPLICATION_CREDENTIALS_JSON" > "$KEY_FILE_PATH"

# Set variables
FUNCTION_NAME="hello_world"
REGION="us-central1"
RUNTIME="python39"
ENTRY_POINT="hello_world"
FUNCTION_DIR="Cloud-Function-Data-Ingest/"  # Adjusted to match the correct path

# Authenticate with Google Cloud using the service account
gcloud auth activate-service-account --key-file="$KEY_FILE_PATH"
gcloud config set project "$PROJECT_ID"

# Check if the function directory exists
if [ ! -d "$FUNCTION_DIR" ]; then
  echo "Function directory $FUNCTION_DIR does not exist."
  exit 1
fi

# Navigate to the function's directory
cd "$FUNCTION_DIR"

# Deploy the Cloud Function
gcloud functions deploy "$FUNCTION_NAME" \
  --runtime "$RUNTIME" \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point "$ENTRY_POINT" \
  --region "$REGION"

# Check if the deployment was successful
if [ $? -eq 0 ]; then
    echo "Cloud Function deployed successfully!"
    FUNCTION_URL=$(gcloud functions describe "$FUNCTION_NAME" --region "$REGION" --format 'value(httpsTrigger.url)')
    echo "Function URL: $FUNCTION_URL"
else
    echo "Failed to deploy Cloud Function."
fi

# Clean up the temporary file
rm -f "$KEY_FILE_PATH"
