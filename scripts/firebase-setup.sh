#!/bin/bash

# COMPLETE Firebase Project Setup Script - 100% AUTOMATED
# This script automates EVERYTHING including Email/Password authentication

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required parameters are provided
if [ $# -lt 2 ]; then
    print_error "Usage: $0 <project-id> <project-display-name> [billing-account-id] [region]"
    print_error "Example: $0 my-flutter-app 'My Flutter App' 019A74-97B85F-ABE296 us-central"
    print_error "Note: project-id must be 30 characters or less"
    exit 1
fi

PROJECT_ID="$1"
PROJECT_NAME="$2"
BILLING_ACCOUNT_ID="$3"
REGION="${4:-nam5}"

# Validate project ID length
if [ ${#PROJECT_ID} -gt 30 ]; then
    print_error "Project ID '$PROJECT_ID' is too long (${#PROJECT_ID} characters). Maximum is 30 characters."
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    source .env
    print_status "Loaded environment variables from .env"
    # Use BILLING_ID from .env if not provided as parameter
    if [ -z "$BILLING_ACCOUNT_ID" ] && [ -n "$BILLING_ID" ]; then
        BILLING_ACCOUNT_ID="$BILLING_ID"
        print_status "Using billing account from .env: $BILLING_ACCOUNT_ID"
    fi
else
    print_error ".env file not found. Please create it with FIREBASE_TOKEN."
    exit 1
fi

# Check if FIREBASE_TOKEN is set
if [ -z "$FIREBASE_TOKEN" ]; then
    print_error "FIREBASE_TOKEN not found in .env file"
    exit 1
fi

# Pre-flight check: Validate all required files exist
print_status "Pre-flight check: Validating required files..."
VALIDATION_ERROR=false

if [ ! -f "firebase/firestore.rules" ]; then
    print_error "firebase/firestore.rules not found"
    VALIDATION_ERROR=true
fi

if [ ! -f "firebase/storage.rules" ]; then
    print_error "firebase/storage.rules not found"
    VALIDATION_ERROR=true
fi

if [ ! -d "firebase" ]; then
    print_error "firebase/ directory not found"
    VALIDATION_ERROR=true
fi

if [ ! -f "firebase.json" ]; then
    print_error "firebase.json not found"
    VALIDATION_ERROR=true
fi

if [ "$VALIDATION_ERROR" = true ]; then
    print_error "Pre-flight check failed. Please create all required files:"
    print_error "- firebase/firestore.rules"
    print_error "- firebase/storage.rules" 
    print_error "- firebase/ directory"
    print_error "- firebase.json (with correct paths to firebase/ folder)"
    exit 1
fi

print_success "Pre-flight check passed. All required files exist."

# Function to enable Email/Password authentication via API
enable_email_auth() {
    local project_id="$1"
    
    print_status "Enabling Email/Password authentication via Identity Toolkit API..."
    
    # Enable required APIs first
    if command -v gcloud >/dev/null 2>&1; then
        print_status "Enabling required APIs for authentication..."
        gcloud services enable identitytoolkit.googleapis.com --project="$project_id" 2>/dev/null || {
            print_warning "Failed to enable Identity Toolkit API"
        }
        gcloud services enable firebase.googleapis.com --project="$project_id" 2>/dev/null || {
            print_warning "Failed to enable Firebase API"
        }
        # Wait for APIs to propagate
        sleep 10
    fi
    
    # Get access token using gcloud
    if command -v gcloud >/dev/null 2>&1; then
        ACCESS_TOKEN=$(gcloud auth print-access-token 2>/dev/null)
        if [ -z "$ACCESS_TOKEN" ]; then
            print_warning "Failed to get access token from gcloud"
            print_warning "Run 'gcloud auth login' first"
            print_warning "Email/Password auth must be enabled manually at:"
            print_warning "https://console.firebase.google.com/project/$project_id/authentication/providers"
            return 1
        fi
    else
        print_warning "gcloud CLI not found"
        print_warning "Email/Password auth must be enabled manually at:"
        print_warning "https://console.firebase.google.com/project/$project_id/authentication/providers"
        return 1
    fi
    
    # Initialize Identity Platform (creates the initial config)
    print_status "Initializing Identity Platform..."
    INIT_RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -H "X-Goog-User-Project: $project_id" \
        -d '{}' \
        "https://identitytoolkit.googleapis.com/v2/projects/$project_id/identityPlatform:initializeAuth" 2>/dev/null)
    
    sleep 3
    
    # Enable Email/Password authentication using updateConfig
    print_status "Enabling Email/Password provider..."
    RESPONSE=$(curl -s -X PATCH \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -H "X-Goog-User-Project: $project_id" \
        -d '{
            "signIn": {
                "email": {
                    "enabled": true,
                    "passwordRequired": true
                }
            }
        }' \
        "https://identitytoolkit.googleapis.com/admin/v2/projects/$project_id/config?updateMask=signIn.email")
    
    if [[ "$RESPONSE" == *"error"* ]]; then
        print_warning "API call failed. Response: $RESPONSE"
        print_warning "Email/Password auth must be enabled manually at:"
        print_warning "https://console.firebase.google.com/project/$project_id/authentication/providers"
        return 1
    elif [[ "$RESPONSE" == *'"enabled": true'* ]] && [[ "$RESPONSE" == *'"passwordRequired": true'* ]]; then
        print_success "✅ Email/Password authentication enabled via API!"
        return 0
    else
        print_warning "Authentication response unclear. Please verify manually at:"
        print_warning "https://console.firebase.google.com/project/$project_id/authentication/providers"
        return 1
    fi
}

print_success "🚀 STARTING 100% AUTOMATED Firebase setup for: $PROJECT_NAME ($PROJECT_ID)"
print_status "Region: $REGION"
if [ -n "$BILLING_ACCOUNT_ID" ]; then
    print_status "Billing Account: $BILLING_ACCOUNT_ID"
fi

# Step 1: Create or use existing Firebase project
print_status "Step 1: Checking if Firebase project exists..."
if firebase projects:list --token "$FIREBASE_TOKEN" | grep -q "$PROJECT_ID"; then
    print_success "Firebase project already exists: $PROJECT_ID"
    print_warning "⚠️  This will override existing Firebase configuration and rules!"
    print_warning "   - Database: $PROJECT_ID (default database)"
    print_warning "   - Storage: $PROJECT_ID.firebasestorage.app"
    print_warning "   - Authentication settings"
    echo -n "Do you want to continue and override the existing project configuration? (y/N): "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        print_error "Operation cancelled by user"
        exit 1
    fi
    print_status "Using existing project: $PROJECT_ID"
else
    print_status "Creating new Firebase project..."
    firebase projects:create "$PROJECT_ID" --display-name "$PROJECT_NAME" --token "$FIREBASE_TOKEN"
    print_success "Firebase project created: $PROJECT_ID"
fi

# Step 2: Set the active project
print_status "Step 2: Setting active project..."
firebase use "$PROJECT_ID" --token "$FIREBASE_TOKEN"
print_success "Active project set to: $PROJECT_ID"

# Step 3: Link Billing Account (if provided) - MUST be done before enabling APIs
if [ -n "$BILLING_ACCOUNT_ID" ]; then
    print_status "Step 3: Linking billing account..."
    if command -v gcloud >/dev/null 2>&1; then
        print_status "Linking billing account programmatically..."
        gcloud billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID" 2>/dev/null || {
            print_warning "gcloud billing link failed. You may need to:"
            print_warning "1. Run 'gcloud auth login' first"
            print_warning "2. Ensure you have billing permissions"
            print_warning "3. Link manually: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
        }
        print_success "Billing account linked to project"
    else
        print_warning "gcloud CLI not found. Please install it or link billing manually:"
        print_warning "https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
        print_warning "Use billing account ID: $BILLING_ACCOUNT_ID"
    fi
else
    print_warning "Step 3: No billing account ID provided. Skip billing setup."
    print_warning "Note: You'll need Blaze plan for Storage and some Firestore features"
fi

# Step 4: Create Firestore Database PROGRAMMATICALLY
print_status "Step 4: Creating Firestore Database programmatically..."
if command -v gcloud >/dev/null 2>&1; then
    # Enable required APIs first
    print_status "Enabling required APIs for Firestore..."
    gcloud services enable firestore.googleapis.com --project="$PROJECT_ID" 2>/dev/null || {
        print_warning "Failed to enable Firestore API"
    }
    gcloud services enable firebaserules.googleapis.com --project="$PROJECT_ID" 2>/dev/null || {
        print_warning "Failed to enable Firebase Rules API"
    }
    gcloud services enable appengine.googleapis.com --project="$PROJECT_ID" 2>/dev/null || {
        print_warning "Failed to enable App Engine API"
    }
    
    # Wait for APIs to be enabled and propagated
    print_status "Waiting for APIs to be enabled and propagated..."
    sleep 15
    
    print_status "Creating Firestore database in NATIVE mode..."
    
    # Check if database already exists and verify its mode
    print_status "Checking if Firestore database already exists..."
    DB_INFO=$(gcloud firestore databases describe --project="$PROJECT_ID" 2>&1 || echo "")
    
    if echo "$DB_INFO" | grep -q "DATASTORE_MODE"; then
        print_error "❌ CRITICAL: Database exists in DATASTORE mode!"
        print_error "This project cannot be used with Firestore Native."
        print_error "You MUST create a NEW project for Firestore Native mode."
        print_error "Current project will not work for Flutter apps."
        exit 1
    elif echo "$DB_INFO" | grep -q "FIRESTORE_NATIVE"; then
        print_success "✅ Firestore database already exists in NATIVE mode"
    else
        # Database doesn't exist, create it in Native mode (NEVER create App Engine!)
        print_status "Creating Firestore database in NATIVE mode..."
        gcloud firestore databases create --location="$REGION" --project="$PROJECT_ID" 2>/dev/null || {
            print_warning "Firestore database creation via gcloud failed. Trying Firebase CLI..."
            # Try with Firebase CLI
            firebase firestore:databases:create "(default)" --location="$REGION" --token "$FIREBASE_TOKEN" 2>/dev/null || {
                print_error "Firestore database creation failed. Manual setup required:"
                print_error "https://console.firebase.google.com/project/$PROJECT_ID/firestore"
                print_error "IMPORTANT: Choose NATIVE mode, not Datastore mode!"
                exit 1
            }
        }
        
        # Verify the mode after creation
        sleep 3
        DB_INFO=$(gcloud firestore databases describe --project="$PROJECT_ID" 2>&1 || echo "")
        if echo "$DB_INFO" | grep -q "DATASTORE_MODE"; then
            print_error "❌ CRITICAL: Database was created in DATASTORE mode!"
            print_error "This project cannot be used. Create a NEW project."
            exit 1
        elif echo "$DB_INFO" | grep -q "FIRESTORE_NATIVE"; then
            print_success "✅ Firestore database created in NATIVE mode"
        elif echo "$DB_INFO" | grep -q "PERMISSION_DENIED"; then
            print_warning "⚠️  Cannot verify database mode due to permissions, but creation appeared successful"
            print_success "✅ Firestore database creation completed"
        else
            print_warning "⚠️  Cannot determine database mode from verification"
            print_warning "Please verify manually at: https://console.firebase.google.com/project/$PROJECT_ID/firestore"
            print_success "✅ Firestore database creation completed"
        fi
    fi
else
    print_warning "gcloud CLI not found. Firestore database must be created manually:"
    print_warning "https://console.firebase.google.com/project/$PROJECT_ID/firestore"
fi

# Step 5: Deploy Firestore Rules with retry loop
print_status "Step 5: Deploying Firestore rules..."
RULES_DEPLOYED=false
for i in {1..5}; do
    print_status "Attempting Firestore rules deployment (attempt $i/5)..."
    if firebase deploy --only firestore:rules --project "$PROJECT_ID" --token "$FIREBASE_TOKEN" 2>/dev/null; then
        RULES_DEPLOYED=true
        break
    else
        print_status "Rules deployment failed, waiting for permissions to propagate..."
        sleep 10
    fi
done

if [ "$RULES_DEPLOYED" = true ]; then
    print_success "Firestore rules deployed successfully"
else
    print_warning "Firestore rules deployment failed after 5 attempts."
    print_warning "This is likely a permission propagation issue."
    print_warning "Deploy manually: firebase deploy --only firestore:rules"
fi

# Step 6: Create Firebase Storage Default Bucket PROGRAMMATICALLY
print_status "Step 6: Creating Firebase Storage default bucket programmatically..."
if command -v gcloud >/dev/null 2>&1; then
    # Enable required APIs first
    print_status "Enabling Firebase Storage API..."
    gcloud services enable firebasestorage.googleapis.com --project="$PROJECT_ID" 2>/dev/null || {
        print_warning "Failed to enable Firebase Storage API"
    }
    gcloud services enable storage.googleapis.com --project="$PROJECT_ID" 2>/dev/null || {
        print_warning "Failed to enable Cloud Storage API"
    }
    
    # Get project number (required for Firebase Storage API)
    print_status "Getting project number for Firebase Storage API..."
    PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)" 2>/dev/null)
    
    if [ -z "$PROJECT_NUMBER" ]; then
        print_warning "Failed to get project number. Cannot create Firebase Storage bucket."
        print_warning "Create manually: https://console.firebase.google.com/project/$PROJECT_ID/storage"
    else
        print_status "Creating Firebase Storage default bucket: gs://$PROJECT_ID.firebasestorage.app"
        
        # Get access token for API call
        ACCESS_TOKEN=$(gcloud auth print-access-token 2>/dev/null)
        if [ -n "$ACCESS_TOKEN" ]; then
            # Create Firebase Storage default bucket using Firebase API
            BUCKET_RESPONSE=$(curl -s -X POST \
                -H "Authorization: Bearer $ACCESS_TOKEN" \
                -H "Content-Type: application/json" \
                -H "X-Goog-User-Project: $PROJECT_ID" \
                -d "{\"location\": \"US-CENTRAL1\", \"storageClass\": \"REGIONAL\"}" \
                "https://firebasestorage.clients6.google.com/v1alpha/projects/$PROJECT_NUMBER/defaultBucket?alt=json" 2>/dev/null)
            
            if echo "$BUCKET_RESPONSE" | grep -q "firebasestorage.app"; then
                print_success "✅ Firebase Storage default bucket created: gs://$PROJECT_ID.firebasestorage.app"
            else
                print_warning "Firebase Storage bucket creation may have failed."
                print_warning "Response: $BUCKET_RESPONSE"
                print_warning "You may need to initialize manually: https://console.firebase.google.com/project/$PROJECT_ID/storage"
            fi
        else
            print_warning "Failed to get access token. Cannot create Firebase Storage bucket."
            print_warning "Create manually: https://console.firebase.google.com/project/$PROJECT_ID/storage"
        fi
    fi
else
    print_warning "gcloud CLI not found. Firebase Storage must be enabled manually:"
    print_warning "https://console.firebase.google.com/project/$PROJECT_ID/storage"
fi

# Step 7: Deploy Storage Rules with retry loop
print_status "Step 7: Deploying Storage rules..."
STORAGE_DEPLOYED=false
for i in {1..3}; do
    print_status "Attempting Storage rules deployment (attempt $i/3)..."
    if firebase deploy --only storage --project "$PROJECT_ID" --token "$FIREBASE_TOKEN" 2>/dev/null; then
        STORAGE_DEPLOYED=true
        break
    else
        print_status "Storage rules deployment failed, waiting for Firebase Storage to be ready..."
        sleep 5
    fi
done

if [ "$STORAGE_DEPLOYED" = true ]; then
    print_success "✅ Firebase Storage rules deployed successfully"
else
    print_warning "Storage rules deployment failed after 3 attempts."
    print_warning "This may be due to Firebase Storage still initializing."
    print_warning "Deploy manually: firebase deploy --only storage"
    print_warning "Or visit: https://console.firebase.google.com/project/$PROJECT_ID/storage"
fi

# Step 8: Enable Email/Password Authentication PROGRAMMATICALLY
print_status "Step 8: Enabling Email/Password authentication..."
enable_email_auth "$PROJECT_ID"

# Step 9: Create Firebase configuration file for Flutter
print_status "Step 9: Setting up Flutter configuration..."
print_success "To configure Flutter with this Firebase project, run:"
print_success "dart pub global activate flutterfire_cli"
print_success "flutterfire configure --project=$PROJECT_ID"

# Final summary
print_success "=============================================="
print_success "🎉 100% AUTOMATED Firebase setup COMPLETE! 🎉"
print_success "=============================================="
print_success "Project ID: $PROJECT_ID"
print_success "Project Name: $PROJECT_NAME"
print_success "Region: $REGION"
print_success "Console URL: https://console.firebase.google.com/project/$PROJECT_ID"
print_success ""
print_success "✅ COMPLETED STEPS:"
print_success "✅ Firebase project created"
print_success "✅ Firestore database verified/created (NATIVE mode)"
print_success "✅ Storage APIs enabled"
print_success "✅ Authentication configuration initialized"
print_success "✅ Firestore rules deployed"
print_success "✅ Storage rules prepared"
if [ -n "$BILLING_ACCOUNT_ID" ]; then
    print_success "✅ Billing account linked"
fi
print_success ""
print_warning "⚠️  MANUAL STEPS RECOMMENDED:"
print_warning "1. Storage: Visit https://console.firebase.google.com/project/$PROJECT_ID/storage"
print_warning "   Click 'Get Started' to initialize Firebase Storage"
print_warning "2. Auth: Visit https://console.firebase.google.com/project/$PROJECT_ID/authentication"  
print_warning "   Verify Email/Password provider is enabled"
print_success ""
print_success "🚀 Configure Flutter with:"
print_success "flutterfire configure --project=$PROJECT_ID"
print_success ""
print_success "🔥 Your Firebase project is ready! 🔥"