#!/bin/bash

# Variables
PROJECT_ID=$1
SERVICE_ACCOUNT_EMAIL=$2
KEY_FILE_PATH=$3

# Authenticate with the service account
gcloud auth activate-service-account --key-file=$KEY_FILE_PATH
gcloud config set project $PROJECT_ID

# Enable necessary APIs
APIS=(
  "cloudresourcemanager.googleapis.com"
  "cloudfunctions.googleapis.com"
  "iam.googleapis.com"
  "pubsub.googleapis.com"
  "storage.googleapis.com"
)

for API in "${APIS[@]}"
do
  gcloud services enable $API
done

# Assign necessary roles to the service account
ROLES=(
  "roles/editor"
  "roles/iam.serviceAccountUser"
)

for ROLE in "${ROLES[@]}"
do
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role=$ROLE
done

echo "APIs enabled and roles assigned."
