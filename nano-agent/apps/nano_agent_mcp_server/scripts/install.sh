#!/usr/bin/env bash

# Nano Agent Installation Script
# This script installs the nano-agent MCP server as a global uv tool

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pyproject.toml" ]; then
    print_error "Please run this script from the apps/nano_agent_mcp_server directory"
    exit 1
fi

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    print_error "uv is not installed. Please install it first:"
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "  or"
    echo "  brew install uv"
    exit 1
fi

print_info "Installing nano-agent as a global uv tool..."

# Install the package as an editable tool
if uv tool install -e . ; then
    print_info "✅ Successfully installed nano-agent"
else
    print_error "Failed to install nano-agent"
    exit 1
fi

# Verify installation
if command -v nano-agent &> /dev/null; then
    NANO_AGENT_PATH=$(which nano-agent)
    print_info "nano-agent installed at: $NANO_AGENT_PATH"
else
    print_warning "nano-agent installed but not found in PATH"
    print_warning "You may need to add ~/.local/bin to your PATH"
fi
