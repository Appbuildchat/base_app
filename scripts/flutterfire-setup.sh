#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if project ID is provided
if [ $# -lt 1 ]; then
    print_error "Usage: $0 <firebase-project-id> [platform1,platform2,...]"
    print_error "Example: $0 carrotmarket-test android,ios"
    print_error "Platforms: android, ios, web, macos, windows, linux"
    exit 1
fi

PROJECT_ID="$1"
PLATFORMS="${2:-android,ios,web}"  # Default to android and ios

print_info "Setting up FlutterFire for project: $PROJECT_ID"
print_info "Platforms: $PLATFORMS"

# Load environment variables if .env exists
if [ -f .env ]; then
    print_info "Loading environment variables from .env"
    source .env
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check if FlutterFire CLI is installed
if ! command -v flutterfire &> /dev/null; then
    print_warning "FlutterFire CLI not found. Installing..."
    dart pub global activate flutterfire_cli
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.pub-cache/bin:"* ]]; then
        print_info "Adding FlutterFire CLI to PATH"
        export PATH="$PATH:$HOME/.pub-cache/bin"
        
        # Add to shell config files
        for config_file in ~/.bashrc ~/.zshrc ~/.profile; do
            if [ -f "$config_file" ]; then
                if ! grep -q "\.pub-cache/bin" "$config_file"; then
                    echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> "$config_file"
                    print_info "Updated $config_file with Flutter pub cache path"
                fi
            fi
        done
    fi
fi

# Function to authenticate FlutterFire CLI
authenticate_flutterfire() {
    print_info "Authenticating FlutterFire CLI..."
    
    if [ -n "$FIREBASE_TOKEN" ]; then
        print_warning "FlutterFire CLI doesn't support token authentication directly"
        print_info "Using Firebase login for FlutterFire authentication"
    fi
    
    # Check if already logged in to Firebase
    if ! firebase projects:list &> /dev/null; then
        print_warning "Firebase CLI not authenticated. Please login first:"
        if [ -n "$FIREBASE_TOKEN" ]; then
            print_info "Using token authentication..."
            firebase login:ci --token "$FIREBASE_TOKEN"
        else
            firebase login
        fi
    fi
    
    # FlutterFire CLI uses the same authentication as Firebase CLI
    print_success "Firebase authentication ready"
}

# Function to verify project exists
verify_project() {
    print_info "Verifying project '$PROJECT_ID' exists and is accessible..."
    
    if [ -n "$FIREBASE_TOKEN" ]; then
        if ! firebase projects:list --token "$FIREBASE_TOKEN" | grep -q "$PROJECT_ID"; then
            print_error "Project '$PROJECT_ID' not found in your Firebase account"
            print_info "Available projects:"
            firebase projects:list --token "$FIREBASE_TOKEN" | grep "│" | head -20
            exit 1
        fi
    else
        if ! firebase projects:list | grep -q "$PROJECT_ID"; then
            print_error "Project '$PROJECT_ID' not found in your Firebase account"
            print_info "Available projects:"
            firebase projects:list | grep "│" | head -20
            exit 1
        fi
    fi
    
    print_success "Project '$PROJECT_ID' verified"
}

# Function to check if this is a Flutter project
check_flutter_project() {
    if [ ! -f "pubspec.yaml" ]; then
        print_error "This doesn't appear to be a Flutter project (no pubspec.yaml found)"
        exit 1
    fi
    
    if ! grep -q "flutter:" pubspec.yaml; then
        print_error "This doesn't appear to be a Flutter project (no flutter section in pubspec.yaml)"
        exit 1
    fi
    
    print_success "Flutter project verified"
}

# Function to run FlutterFire configure
configure_flutterfire() {
    print_info "Configuring FlutterFire for platforms: $PLATFORMS"

    # Remove existing Firebase configuration files for clean setup
    print_info "Removing existing Firebase configuration files for clean setup..."
    rm -f android/app/google-services.json
    rm -f ios/Runner/GoogleService-Info.plist
    rm -f lib/firebase_options.dart
    print_info "Existing Firebase configuration files removed"

    # Create the flutterfire configure command
    FLUTTERFIRE_CMD="flutterfire configure --project=$PROJECT_ID"
    
    # Add platforms if specified
    if [ "$PLATFORMS" != "all" ]; then
        FLUTTERFIRE_CMD="$FLUTTERFIRE_CMD --platforms=$PLATFORMS"
    fi
    
    print_info "Running: $FLUTTERFIRE_CMD"
    
    # Run the command
    if eval "$FLUTTERFIRE_CMD"; then
        print_success "FlutterFire configuration completed"
    else
        print_error "FlutterFire configuration failed"
        return 1
    fi
}

# Function to add Firebase dependencies
add_firebase_dependencies() {
    print_info "Adding Firebase dependencies to pubspec.yaml..."
    
    # Core Firebase
    flutter pub add firebase_core
    
    # Automatically add common Firebase packages
    print_info "Adding common Firebase packages..."
    flutter pub add firebase_auth
    flutter pub add cloud_firestore
    flutter pub add firebase_storage
    flutter pub add firebase_analytics
    flutter pub add firebase_crashlytics
    
    print_success "Firebase packages added"
    
    # Get dependencies
    flutter pub get
}


# Function to deploy Firebase Functions
deploy_firebase_functions() {
    print_info "Installing Firebase Functions dependencies..."
    
    # Install required packages in functions directory
    cd functions
    npm install firebase-functions firebase-admin googleapis jsonwebtoken
    npm install moment-timezone
    npm install eslint-config-google
    cd ..
    
    if [ $? -eq 0 ]; then
        print_success "Firebase Functions dependencies installed successfully"
    else
        print_warning "Some dependencies may have failed to install"
    fi
    
    print_info "Deploying functions to Firebase project: $PROJECT_ID"
    
    if firebase deploy --only functions; then
        print_success "Firebase Functions deployed successfully!"
        print_info "Your functions are now live at:"
        print_info "https://console.firebase.google.com/project/$PROJECT_ID/functions"
    else
        print_error "Firebase Functions deployment failed"
        print_info "Common issues and solutions:"
        print_info "1. Check that your project is on Blaze billing plan"
        print_info "2. Review function logs: firebase functions:log"
        print_info "3. Check ESLint errors in functions/index.js"
        print_info "4. Ensure all lines in index.js are under 80 characters"
        return 1
    fi
}

# Function to verify firebase_options.dart was created
verify_firebase_options() {
    print_info "Verifying Flutter Firebase configuration..."
    
    if [ -f "lib/firebase_options.dart" ]; then
        print_success "firebase_options.dart generated successfully"
        print_info "Firebase configuration is now available for your Flutter app"
    else
        print_warning "firebase_options.dart not found - FlutterFire configuration may have failed"
        return 1
    fi
}

# Function to show next steps
show_next_steps() {
    print_success "FlutterFire setup completed!"
    print_info "Next steps:"
    echo "  1. Import Firebase in your main.dart:"
    echo "     import 'package:firebase_core/firebase_core.dart';"
    echo "     import 'firebase_options.dart';"
    echo ""
    echo "  2. Initialize Firebase in your main() function:"
    echo "     await Firebase.initializeApp("
    echo "       options: DefaultFirebaseOptions.currentPlatform,"
    echo "     );"
    echo ""
    echo "  3. Your firebase_options.dart file has been generated with your project configuration"
    echo ""
    if [ -f "lib/firebase_options.dart" ]; then
        print_success "Configuration file created: lib/firebase_options.dart"
    fi
    
    if [ -d "functions" ]; then
        echo ""
        print_info "Firebase Functions setup:"
        echo "  4. Edit functions/index.js to add your cloud functions"
        echo "  5. Remember ESLint rules:"
        echo "     - Use double quotes for all strings"
        echo "     - Keep lines under 80 characters"
        echo "     - No spaces inside brackets: {test} not { test }"
        echo "     - End file with empty line"
        echo "  6. Deploy functions: firebase deploy --only functions"
        echo "  7. View functions: https://console.firebase.google.com/project/$PROJECT_ID/functions"
    fi
}

# Main execution
main() {
    print_info "Starting FlutterFire setup for project: $PROJECT_ID"
    
    # Pre-flight checks
    check_flutter_project
    authenticate_flutterfire
    verify_project
    
    # Configure FlutterFire
    if configure_flutterfire; then
        print_info "FlutterFire configuration successful"
        
        # Verify Firebase options were generated
        verify_firebase_options
        
        # Ask about adding dependencies
        add_firebase_dependencies
        
        # Deploy Firebase Functions
        print_info "Deploying Firebase Functions..."
        if deploy_firebase_functions; then
            print_success "Firebase Functions deployment completed"
        else
            print_warning "Firebase Functions deployment skipped or failed"
            print_info "You can deploy manually later with: firebase deploy --only functions"
        fi
        
        # Show next steps
        show_next_steps
        
        print_success "FlutterFire setup completed successfully!"
    else
        print_error "FlutterFire setup failed"
        exit 1
    fi
}

# Run main function
main "$@"