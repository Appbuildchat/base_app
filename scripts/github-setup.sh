#!/bin/bash

# GitHub Repository Setup Script
# This script creates a new GitHub repository and sets up git with initial commit

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
if [ $# -lt 1 ]; then
    print_error "Usage: $0 <project-name> [description] [visibility]"
    print_error "Example: $0 my-flutter-app 'My awesome Flutter app' public"
    print_error "Visibility options: public, private (default: private)"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DESCRIPTION="${2:-A Flutter project created with automated setup}"
VISIBILITY="${3:-private}"

# Validate project name (GitHub repository naming rules)
if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    print_error "Invalid project name. GitHub repository names can only contain:"
    print_error "• Letters (a-z, A-Z)"
    print_error "• Numbers (0-9)"
    print_error "• Dots (.), hyphens (-), and underscores (_)"
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    source .env
    print_status "Loaded environment variables from .env"
else
    print_error ".env file not found. Please create it with GITHUB_TOKEN."
    exit 1
fi

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    print_error "GITHUB_TOKEN not found in .env file"
    print_error "Generate a token at: https://github.com/settings/tokens"
    print_error "Required scopes: repo, write:org (for organization repositories)"
    exit 1
fi

# Set GitHub organization (can be overridden in .env)
GITHUB_ORG="${GITHUB_ORG:-AppbuildchatClientApp}"

# Get GitHub username for authentication verification
print_status "Getting GitHub user information..."
GITHUB_USER=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user | grep '"login"' | cut -d'"' -f4)

if [ -z "$GITHUB_USER" ]; then
    print_error "Failed to get GitHub username. Check your GITHUB_TOKEN."
    exit 1
fi

print_success "GitHub user: $GITHUB_USER"
print_success "Creating repository in organization: $GITHUB_ORG"

print_success "🚀 STARTING GitHub repository setup for: $PROJECT_NAME"
print_status "Description: $PROJECT_DESCRIPTION"
print_status "Visibility: $VISIBILITY"
print_status "Owner: $GITHUB_USER"

# Step 1: Check if repository already exists
print_status "Step 1: Checking if repository already exists..."
REPO_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_ORG/$PROJECT_NAME")

if [ "$REPO_EXISTS" = "200" ]; then
    print_warning "Repository $GITHUB_ORG/$PROJECT_NAME already exists!"
    echo -n "Do you want to continue and push to the existing repository? (y/N): "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        print_error "Operation cancelled by user"
        exit 1
    fi
    print_status "Using existing repository: $GITHUB_ORG/$PROJECT_NAME"
    REPO_CREATED=false
else
    print_status "Repository does not exist. Will create new repository."
    REPO_CREATED=true
fi

# Step 2: Initialize/Reset local git repository
print_status "Step 2: Setting up local git repository..."

# Remove existing .git if it exists
if [ -d ".git" ]; then
    print_status "Removing existing git repository..."
    rm -rf .git
fi

# Initialize new git repository
git init
print_success "Git repository initialized"

# Configure git if not already configured
if [ -z "$(git config --global user.name 2>/dev/null)" ]; then
    print_warning "Git user.name not configured globally"
    git config user.name "$GITHUB_USER"
    print_status "Set local git user.name to: $GITHUB_USER"
fi

if [ -z "$(git config --global user.email 2>/dev/null)" ]; then
    print_warning "Git user.email not configured globally"
    # Try to get email from GitHub API
    GITHUB_EMAIL=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user | grep '"email"' | cut -d'"' -f4 | head -1)
    
    if [ -n "$GITHUB_EMAIL" ] && [ "$GITHUB_EMAIL" != "null" ]; then
        git config user.email "$GITHUB_EMAIL"
        print_status "Set local git user.email to: $GITHUB_EMAIL"
    else
        git config user.email "$GITHUB_USER@users.noreply.github.com"
        print_status "Set local git user.email to: $GITHUB_USER@users.noreply.github.com"
    fi
fi

# Step 3: Create GitHub repository (if it doesn't exist)
if [ "$REPO_CREATED" = true ]; then
    print_status "Step 3: Creating GitHub repository..."
    
    # Prepare JSON payload - ensure completely empty repository
    JSON_PAYLOAD=$(cat <<EOF
{
  "name": "$PROJECT_NAME",
  "description": "$PROJECT_DESCRIPTION",
  "private": $([ "$VISIBILITY" = "private" ] && echo "true" || echo "false"),
  "auto_init": false
}
EOF
)

    # Create repository in organization
    RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD" \
        "https://api.github.com/orgs/$GITHUB_ORG/repos")

    # Check if repository was created successfully
    if echo "$RESPONSE" | grep -q '"clone_url"'; then
        print_success "GitHub repository created: https://github.com/$GITHUB_ORG/$PROJECT_NAME"
    else
        print_error "Failed to create GitHub repository"
        print_error "Response: $RESPONSE"
        exit 1
    fi
else
    print_status "Step 3: Using existing GitHub repository"
fi

# Step 4: Add all files and create initial commit
print_status "Step 4: Creating initial commit..."

# Add all files
git add .

# Check if there are files to commit
if git diff --staged --quiet; then
    print_warning "No changes to commit"
else
    # Create initial commit
    COMMIT_MESSAGE="Initial commit: $PROJECT_NAME Flutter project

🚀 Project created with automated setup
- Flutter project: $PROJECT_NAME  
- Firebase integration ready
- FlutterFire configured
- Automated development environment

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

    git commit -m "$COMMIT_MESSAGE"
    print_success "Initial commit created"
fi

# Step 5: Add remote origin and push
print_status "Step 5: Setting up remote origin and pushing..."

# Remove existing remote if it exists
if git remote get-url origin 2>/dev/null; then
    git remote remove origin
    print_status "Removed existing remote origin"
fi

# Add new remote origin with token authentication
git remote add origin "https://$GITHUB_TOKEN@github.com/$GITHUB_ORG/$PROJECT_NAME.git"
print_success "Remote origin added: https://github.com/$GITHUB_ORG/$PROJECT_NAME.git"

# Set default branch to main
git branch -M main

# Verify repository exists before pushing
print_status "Verifying repository exists..."
sleep 2  # Small delay to ensure repository is fully created

VERIFY_REPO=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_ORG/$PROJECT_NAME")

if [ "$VERIFY_REPO" != "200" ]; then
    print_error "Repository verification failed. Repository may not be fully created yet."
    print_warning "Please wait a moment and try pushing manually:"
    print_warning "git push -u origin main"
    exit 1
fi

# Push to GitHub
print_status "Pushing to GitHub repository..."
if git push -u origin main; then
    print_success "Code pushed to GitHub successfully!"
else
    print_error "Failed to push to GitHub"
    print_warning "Repository should be completely empty. If this fails:"
    print_warning "1. Check your GITHUB_TOKEN permissions for organization: $GITHUB_ORG"
    print_warning "2. Verify you have write access to the organization"
    print_warning "3. Repository URL: https://github.com/$GITHUB_ORG/$PROJECT_NAME"
    exit 1
fi

# Final summary
print_success "=============================================="
print_success "🎉 GitHub repository setup COMPLETE! 🎉"
print_success "=============================================="
print_success "Repository: https://github.com/$GITHUB_ORG/$PROJECT_NAME"
print_success "Clone URL: git@github.com:$GITHUB_ORG/$PROJECT_NAME.git"
print_success "HTTPS URL: https://github.com/$GITHUB_ORG/$PROJECT_NAME.git"
print_success ""
print_success "✅ COMPLETED TASKS:"
print_success "✅ GitHub repository created ($VISIBILITY)"
print_success "✅ Local git repository initialized"
print_success "✅ Initial commit with project customization"
print_success "✅ Code pushed to GitHub"
print_success ""
print_success "🚀 Next steps:"
print_success "1. Visit your repository: https://github.com/$GITHUB_ORG/$PROJECT_NAME"
print_success "2. Configure repository settings if needed (branch protection, etc.)"
print_success "3. Start developing your Flutter app!"
print_success ""
print_success "🔥 Your GitHub repository is ready for development! 🔥"