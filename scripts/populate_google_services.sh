#!/bin/bash
set -e

GOOGLE_SERVICES_SRC="android/app/google-services.json"
GOOGLE_SERVICES_DEST="android/app/google-services.json"

if [ -n "${FIREBASE_PROJECT_ID}" ] && [ "${FIREBASE_PROJECT_ID}" != "YOUR_PROJECT_ID" ]; then
  echo "Populating google-services.json with real Firebase values..."
  sed -i "s/\${FIREBASE_PROJECT_NUMBER}/${FIREBASE_PROJECT_NUMBER}/g" ${GOOGLE_SERVICES_DEST}
  sed -i "s/\${FIREBASE_PROJECT_ID}/${FIREBASE_PROJECT_ID}/g" ${GOOGLE_SERVICES_DEST}
  sed -i "s/\${FIREBASE_APP_ID}/${FIREBASE_APP_ID}/g" ${GOOGLE_SERVICES_DEST}
  sed -i "s/\${FIREBASE_API_KEY}/${FIREBASE_API_KEY}/g" ${GOOGLE_SERVICES_DEST}
  echo "google-services.json populated successfully"
else
  echo "No Firebase secrets available, using fallback google-services.json"
  cat > android/app/google-services.json << 'EOF'
{
  "project_info": {
    "project_number": "123456789012",
    "project_id": "trtravel-fallback",
    "storage_bucket": "trtravel-fallback.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abc123def456",
        "android_client_info": {
          "package_name": "com.example.trtravel"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyFallbackKeyForCIPurposes123"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
EOF
  echo "Fallback google-services.json created"
fi
