#!/bin/bash

# Project Customization Script
# This script replaces all occurrences of 'flutter_basic_project' with a new package name

set -e

# Colors and styles
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ASCII Art
echo -e "${CYAN}"
cat << "EOF"
    _    ____   ____     _             _   
   / \  | __ ) / ___|___| |_ __ _ _ __| |_ 
  / _ \ |  _ \| |   / __| __/ _` | '__| __|
 / ___ \| |_) | |___\__ \ || (_| | |  | |_ 
/_/   \_\____/ \____|___/\__\__,_|_|   \__|
                           
  Project Customizer v1.0  
EOF
echo -e "${NC}"

# Animated loading dots
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⣾⣽⣻⢿⡿⣟⣯⣷'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🛠️  Development Environment Setup${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "${DIM}This script will set up your complete development environment and customize the project.${NC}"
echo

# Environment checks and setup
check_dependency() {
    local name="$1"
    local command="$2"
    local version_flag="$3"
    local expected_version="$4"
    
    echo -n -e "  ${CYAN}➤${NC} Checking ${BOLD}$name${NC}... "
    
    if command -v "$command" &> /dev/null; then
        local current_version
        if [ -n "$version_flag" ]; then
            current_version=$($command $version_flag 2>/dev/null | head -n 1)
        else
            current_version="installed"
        fi
        
        if [ -n "$expected_version" ] && [[ "$current_version" != *"$expected_version"* ]]; then
            echo -e "${YELLOW}⚠ Found $current_version, expected $expected_version${NC}"
            return 1
        else
            echo -e "${GREEN}✓ $current_version${NC}"
            return 0
        fi
    else
        echo -e "${RED}✗ Not found${NC}"
        return 1
    fi
}

install_node() {
    echo -e "  ${BLUE}📦${NC} Installing Node.js v22.16.0..."
    if command -v nvm &> /dev/null; then
        nvm install 22.16.0
        nvm use 22.16.0
        nvm alias default 22.16.0
    else
        echo -e "  ${RED}✗${NC} nvm not found. Please install Node.js v22.16.0 manually from https://nodejs.org/"
        return 1
    fi
}

install_claude() {
    echo -e "  ${BLUE}📦${NC} Installing Claude Code CLI..."
    npm install -g @anthropic-ai/claude-code
}

install_uvx() {
    echo -e "  ${BLUE}📦${NC} Installing uvx..."
    if command -v pip &> /dev/null; then
        pip install uv
    elif command -v pip3 &> /dev/null; then
        pip3 install uv
    else
        echo -e "  ${RED}✗${NC} pip not found. Please install Python and pip first."
        return 1
    fi
}

echo -e "${CYAN}🔍 Checking dependencies...${NC}"
echo

# Check Node.js - allow any 22.x version
if ! check_dependency "Node.js" "node" "--version" "v22."; then
    install_node || exit 1
fi

# Check Claude Code
if ! check_dependency "Claude Code" "claude" "--version" ""; then
    install_claude || exit 1
fi

# Check uvx
if ! check_dependency "uvx" "uvx" "--version" ""; then
    install_uvx || exit 1
fi

# Check Flutter
if ! check_dependency "Flutter" "flutter" "--version" "3.32.4"; then
    echo -e "  ${YELLOW}⚠${NC} Please ensure Flutter 3.32.4 is installed and in your PATH"
    echo -e "  ${DIM}Download from: https://docs.flutter.dev/get-started/install${NC}"
fi

echo
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📦 Project Package Name Customization${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "${DIM}Now we'll customize your project package name.${NC}"
echo

# Function to convert snake_case or kebab-case to camelCase
convert_to_camel_case() {
    local input="$1"
    # Convert first character to lowercase and subsequent characters after - or _ to uppercase
    echo "$input" | sed 's/[-_]\(.\)/\U\1/g' | sed 's/^\(.\)/\L\1/'
}

# Prompt for new package name with styled input
echo -e "${CYAN}➤${NC} ${BOLD}Enter your new package name:${NC} "
echo -e "  ${DIM}(lowercase letters, numbers, underscores, and hyphens allowed)${NC}"
echo -n -e "  ${GREEN}▸${NC} "
read new_package_name

# Convert input to camelCase for package name
camel_case_name=$(convert_to_camel_case "$new_package_name")

# Create display name from camelCase (add spaces before capitals and capitalize words)
display_name=$(echo "$camel_case_name" | sed 's/\([A-Z]\)/ \1/g' | sed 's/^ *//' | sed 's/\b\w/\U&/g')

# Create Firebase project ID from camelCase (convert to lowercase for Firebase rules)
firebase_project_id=$(echo "$camel_case_name" | tr '[:upper:]' '[:lower:]')

# Validate input
if [[ -z "$new_package_name" ]]; then
    echo
    echo -e "${RED}✗ Error:${NC} Package name cannot be empty."
    exit 1
fi

if [[ ! "$new_package_name" =~ ^[a-z][a-z0-9_-]*$ ]]; then
    echo
    echo -e "${RED}✗ Error:${NC} Invalid format. Package name must:"
    echo -e "  ${DIM}• Start with a lowercase letter"
    echo -e "  • Contain only lowercase letters, numbers, underscores, and hyphens${NC}"
    exit 1
fi

echo
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📁 Creating project directory...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Step 1: Create new project directory using camelCase name
PROJECT_DIR="../$camel_case_name"
echo -e "  ${GREEN}✓${NC} Creating project directory: ${CYAN}$PROJECT_DIR${NC}..."

if [ -d "$PROJECT_DIR" ]; then
    echo -e "  ${YELLOW}⚠${NC} Directory '$PROJECT_DIR' already exists!"
    echo -n "Do you want to overwrite it? (y/N): "
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo -e "  ${RED}✗${NC} Operation cancelled by user"
        exit 1
    fi
    echo -e "  ${GREEN}✓${NC} Removing existing directory..."
    rm -rf "$PROJECT_DIR"
fi

# Copy current directory to new project directory
echo -e "  ${GREEN}✓${NC} Copying project files to new directory..."
cp -r . "$PROJECT_DIR"

# Remove the start.sh script from the new directory (not needed in final project)
if [ -f "$PROJECT_DIR/start.sh" ]; then
    rm "$PROJECT_DIR/start.sh"
fi

# Ensure setup scripts are executable in the new directory
chmod +x "$PROJECT_DIR"/scripts/*.sh 2>/dev/null || true

echo -e "  ${GREEN}✓${NC} Project copied to: ${CYAN}$PROJECT_DIR${NC}"

# Change to the new project directory for all subsequent operations
cd "$PROJECT_DIR"
echo -e "  ${GREEN}✓${NC} Changed to project directory"

echo
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔄 Processing files...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Find and replace all project name patterns
echo -e "  ${CYAN}🔍${NC} Searching for files containing project name patterns..."

# Pattern 1: flutter_basic_project (underscore)
mapfile -t files_underscore < <(grep -r -l "flutter_basic_project" . --exclude-dir=".git" 2>/dev/null || true)

# Pattern 2: flutterBasicProject (camelCase)
mapfile -t files_camelcase < <(grep -r -l "flutterBasicProject" . --exclude-dir=".git" 2>/dev/null || true)

# Pattern 3: Flutter Basic Project (display name)
mapfile -t files_displayname < <(grep -r -l "Flutter Basic Project" . --exclude-dir=".git" 2>/dev/null || true)

# Pattern 4: com.appbuildchat.flutterBasicProject (bundle identifier with dots)
mapfile -t files_bundleid < <(grep -r -l "com\.appbuildchat\.flutterBasicProject" . --exclude-dir=".git" 2>/dev/null || true)

# Pattern 5: Android .gradle.kts files (Kotlin DSL)
mapfile -t files_gradle_kts < <(grep -r -l "flutter_basic_project\|flutterBasicProject" . --include="*.gradle.kts" --exclude-dir=".git" 2>/dev/null || true)

# Pattern 6: iOS Bundle ID without dots (in .pbxproj files)
mapfile -t files_ios_bundle < <(grep -r -l "flutterBasicProject" . --include="*.pbxproj" --exclude-dir=".git" 2>/dev/null || true)

# Combine all files and remove duplicates
all_files=()
for file in "${files_underscore[@]}" "${files_camelcase[@]}" "${files_displayname[@]}" "${files_bundleid[@]}" "${files_gradle_kts[@]}" "${files_ios_bundle[@]}"; do
    if [[ ! " ${all_files[*]} " =~ " ${file} " ]]; then
        all_files+=("$file")
    fi
done

if [ ${#all_files[@]} -eq 0 ]; then
    echo -e "  ${YELLOW}⚠${NC} No files found containing project name patterns"
else
    echo -e "  ${GREEN}✓${NC} Found ${#all_files[@]} file(s) to process"
    echo

    # Process each file with all three pattern replacements
    for file in "${all_files[@]}"; do
        echo -e "  ${GREEN}✓${NC} Processing: ${CYAN}$file${NC}"

        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS requires empty string after -i
            sed -i '' "s/flutter_basic_project/$firebase_project_id/g" "$file" 2>/dev/null || echo -e "  ${RED}✗ Error processing $file (pattern 1 - underscore to lowercase)${NC}"
            sed -i '' "s/flutterBasicProject/$firebase_project_id/g" "$file" 2>/dev/null || echo -e "  ${RED}✗ Error processing $file (pattern 2 - camelCase to lowercase)${NC}"
            sed -i '' "s/Flutter Basic Project/$display_name/g" "$file" 2>/dev/null || echo -e "  ${RED}✗ Error processing $file (pattern 3 - display name)${NC}"
            sed -i '' "s/com\.appbuildchat\.flutterBasicProject/com.appbuildchat.$firebase_project_id/g" "$file" 2>/dev/null || echo -e "  ${RED}✗ Error processing $file (pattern 4 - bundle ID with dots)${NC}"
        else
            # Linux
            sed -i "s/flutter_basic_project/$firebase_project_id/g" "$file" 2>/dev/null || echo -e "  ${RED}✗ Error processing $file (pattern 1 - underscore to lowercase)${NC}"
            sed -i "s/flutterBasicProject/$firebase_project_id/g" "$file" 2>/dev/null || echo -e "  ${RED}✗ Error processing $file (pattern 2 - camelCase to lowercase)${NC}"
            sed -i "s/Flutter Basic Project/$display_name/g" "$file" 2>/dev/null || echo -e "  ${RED}✗ Error processing $file (pattern 3 - display name)${NC}"
            sed -i "s/com\.appbuildchat\.flutterBasicProject/com.appbuildchat.$firebase_project_id/g" "$file" 2>/dev/null || echo -e "  ${RED}✗ Error processing $file (pattern 4 - bundle ID with dots)${NC}"
        fi
    done
fi

echo
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🎨 Processing colorset file...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Find colorset file in input directory
INPUT_COLORSET_FILES=(input/colorset_*.com.json)
INPUT_COLORSET=""

if [ ${#INPUT_COLORSET_FILES[@]} -eq 1 ] && [ -f "${INPUT_COLORSET_FILES[0]}" ]; then
    INPUT_COLORSET="${INPUT_COLORSET_FILES[0]}"
    echo -e "  ${GREEN}✓${NC} Found colorset file: ${CYAN}$INPUT_COLORSET${NC}"
elif [ ${#INPUT_COLORSET_FILES[@]} -gt 1 ]; then
    echo -e "  ${YELLOW}⚠${NC} Multiple colorset files found in input directory:"
    for file in "${INPUT_COLORSET_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo -e "    ${DIM}- $file${NC}"
        fi
    done
    echo -e "  ${DIM}Using the first one: ${INPUT_COLORSET_FILES[0]}${NC}"
    INPUT_COLORSET="${INPUT_COLORSET_FILES[0]}"
else
    echo -e "  ${YELLOW}⚠${NC} No colorset file found matching pattern: input/colorset_*.com.json"
fi

# Remove existing colorset.json from assets
if [ -f "assets/colorset.json" ]; then
    echo -e "  ${GREEN}✓${NC} Removing existing assets/colorset.json..."
    rm assets/colorset.json
fi

# Copy and rename input colorset file
if [ -n "$INPUT_COLORSET" ] && [ -f "$INPUT_COLORSET" ]; then
    echo -e "  ${GREEN}✓${NC} Copying colorset from input to assets/colorset.json..."
    cp "$INPUT_COLORSET" assets/colorset.json
    echo -e "  ${GREEN}✓${NC} Colorset file successfully updated!"
else
    echo -e "  ${DIM}Skipping colorset update.${NC}"
fi

echo
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📄 Generating FSD (Functional Specification Document)...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Check if Python is available
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo -e "  ${RED}✗${NC} Python not found. Skipping FSD generation."
    echo -e "  ${DIM}Please install Python to enable FSD generation.${NC}"
    PYTHON_CMD=""
fi

if [ -n "$PYTHON_CMD" ]; then
    # Find CSV file in input directory
    INPUT_CSV_FILES=(input/*_list_P_output.csv)
    INPUT_CSV=""

    if [ ${#INPUT_CSV_FILES[@]} -eq 1 ] && [ -f "${INPUT_CSV_FILES[0]}" ]; then
        INPUT_CSV="${INPUT_CSV_FILES[0]}"
        echo -e "  ${GREEN}✓${NC} Found CSV file: ${CYAN}$INPUT_CSV${NC}"
    elif [ ${#INPUT_CSV_FILES[@]} -gt 1 ]; then
        echo -e "  ${YELLOW}⚠${NC} Multiple CSV files found in input directory:"
        for file in "${INPUT_CSV_FILES[@]}"; do
            if [ -f "$file" ]; then
                echo -e "    ${DIM}- $file${NC}"
            fi
        done
        echo -e "  ${DIM}Using the first one: ${INPUT_CSV_FILES[0]}${NC}"
        INPUT_CSV="${INPUT_CSV_FILES[0]}"
    else
        echo -e "  ${YELLOW}⚠${NC} No CSV file found matching pattern: input/*_list_P_output.csv"
    fi

    if [ -n "$INPUT_CSV" ] && [ -f "$INPUT_CSV" ]; then
        # Create output directory
        mkdir -p output
        echo -e "  ${GREEN}✓${NC} Created output directory"

        # Check if required Python packages are available
        echo -e "  ${CYAN}🔍${NC} Checking Python dependencies..."
        $PYTHON_CMD -c "import openai, pandas" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "  ${YELLOW}⚠${NC} Installing required Python packages..."
            pip install openai pandas 2>/dev/null || pip3 install openai pandas 2>/dev/null
            if [ $? -ne 0 ]; then
                echo -e "  ${RED}✗${NC} Failed to install required packages. Skipping FSD generation."
                echo -e "  ${DIM}Please install manually: pip install openai pandas${NC}"
                INPUT_CSV=""
            else
                echo -e "  ${GREEN}✓${NC} Python dependencies installed"
            fi
        else
            echo -e "  ${GREEN}✓${NC} Python dependencies available"
        fi

        if [ -n "$INPUT_CSV" ]; then
            # Create a temporary Python script to generate FSD
            cat > temp_fsd_generator.py << 'EOF'
import sys
import os
import csv
sys.path.append('ui-starter')

from functions import process_user_folder_filtered
from generate_fsd_md import generate_fsd_md

try:
    # Process the CSV file to get PRD content
    user_id, prd_content = process_user_folder_filtered()
    
    # Generate FSD using the PRD content
    print("📄 Generating FSD document...")
    fsd_output = generate_fsd_md(prd_content)
    
    # Save FSD to output directory
    fsd_path = os.path.join("output", "fsd.md")
    with open(fsd_path, "w", encoding="utf-8") as f:
        f.write(fsd_output)
    
    print(f"✅ FSD successfully generated: {fsd_path}")
    
except Exception as e:
    print(f"❌ Error generating FSD: {str(e)}")
    sys.exit(1)
EOF

            echo -e "  ${GREEN}✓${NC} Running FSD generation..."
            if $PYTHON_CMD temp_fsd_generator.py; then
                echo -e "  ${GREEN}✓${NC} FSD document successfully generated: ${CYAN}output/fsd.md${NC}"
            else
                echo -e "  ${RED}✗${NC} FSD generation failed"
            fi

            # Clean up temporary script
            rm -f temp_fsd_generator.py
        fi
    else
        echo -e "  ${DIM}Skipping FSD generation - no CSV file found.${NC}"
    fi
else
    echo -e "  ${DIM}Skipping FSD generation - Python not available.${NC}"
fi

echo
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🎨 Generating Flutter Screens...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

if [ -n "$PYTHON_CMD" ] && [ -n "$INPUT_CSV" ] && [ -f "$INPUT_CSV" ]; then
    echo -e "  ${GREEN}✓${NC} Running Flutter screen generation..."
    
    # Create temporary script for Flutter screen generation
    cat > temp_flutter_screen_generator.py << 'EOF'
import sys
import os
import glob
sys.path.append('ui-starter')

from functions import process_user_folder_filtered, clean_dart_code
from generate_design_dart import generate_flutter_screens

try:
    # Process the CSV file to get PRD content
    user_id, prd_content = process_user_folder_filtered()
    
    # Generate Flutter screens using the PRD content
    print("🎨 Generating Flutter screens...")
    generated_code = generate_flutter_screens(prd_content)
    
    # Clean the generated code (remove markdown backticks)
    cleaned_code = clean_dart_code(generated_code)
    
    # Ensure output directory exists
    os.makedirs("output", exist_ok=True)
    
    # Save generated Dart file
    output_file = "output/generated_app_screens.dart"
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(cleaned_code)
    
    print(f"✅ Flutter screens successfully generated: {output_file}")
    
except Exception as e:
    print(f"❌ Error generating Flutter screens: {str(e)}")
    sys.exit(1)
EOF
    
    if $PYTHON_CMD temp_flutter_screen_generator.py; then
        echo -e "  ${GREEN}✓${NC} Flutter screens successfully generated: ${CYAN}output/generated_app_screens.dart${NC}"
    else
        echo -e "  ${RED}✗${NC} Flutter screen generation failed"
    fi
    
    # Clean up temporary script
    rm -f temp_flutter_screen_generator.py
else
    echo -e "  ${DIM}Skipping Flutter screen generation - Python or CSV file not available.${NC}"
fi

echo
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📋 Generating UI Guidelines...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Check if generated Flutter screens exist
GENERATED_SCREENS="output/generated_app_screens.dart"
if [ -f "$GENERATED_SCREENS" ] && [ -n "$PYTHON_CMD" ]; then
    echo -e "  ${GREEN}✓${NC} Running UI guideline generation..."
    
    # Create temporary script for UI guideline generation
    cat > temp_ui_guideline_generator.py << 'EOF'
import sys
import os
sys.path.append('ui-starter')

from generate_design_guideline import generate_ui_guideline

try:
    # Read the generated Flutter screens file
    input_file = 'output/generated_app_screens.dart'
    
    if not os.path.exists(input_file):
        print(f"❌ Error: Input file not found: {input_file}")
        sys.exit(1)
    
    # Read the Flutter screen content
    with open(input_file, 'r', encoding='utf-8') as f:
        screen_content = f.read()
    
    print(f"✅ Flutter screen file loaded: {os.path.basename(input_file)}")
    print("📋 Analyzing Flutter code structure and generating UI guidelines...")
    
    # Generate UI guidelines based on the Flutter code
    guideline_content = generate_ui_guideline(screen_content)
    
    # Ensure output and docs directories exist
    os.makedirs("output", exist_ok=True)
    os.makedirs("docs", exist_ok=True)
    
    # Save generated guideline file to both locations
    output_file = "output/ui_guideline.md"
    docs_file = "docs/ui_guideline.md"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(guideline_content)
    
    with open(docs_file, 'w', encoding='utf-8') as f:
        f.write(guideline_content)
    
    # Also update story-planner.md with the new guidelines
    story_planner_file = ".claude/agents/story-planner.md"
    if os.path.exists(story_planner_file):
        # Read the current story-planner.md content
        with open(story_planner_file, 'r', encoding='utf-8') as f:
            story_content = f.read()
        
        # Find the UI Guidelines Content section markers
        start_marker = "## UI Guidelines Content\n**MANDATORY**: All plans MUST strictly follow these guidelines. Must use @lib/core/themes files. These files are app themes contents.\n---\n"
        end_marker = "\n---\n\n## UI Guidelines Enforcement"
        
        start_idx = story_content.find(start_marker)
        end_idx = story_content.find(end_marker, start_idx)
        
        if start_idx != -1 and end_idx != -1:
            # Replace the content between markers
            before_section = story_content[:start_idx + len(start_marker)]
            after_section = story_content[end_idx:]
            
            # Combine with new guideline content
            updated_content = before_section + guideline_content + after_section
            
            # Write back to story-planner.md
            with open(story_planner_file, 'w', encoding='utf-8') as f:
                f.write(updated_content)
            
            print(f"✅ UI guidelines successfully generated:")
            print(f"   📁 {output_file}")
            print(f"   📁 {docs_file}")
            print(f"   📁 .claude/agents/story-planner.md (UI Guidelines section updated)")
        else:
            print(f"✅ UI guidelines successfully generated:")
            print(f"   📁 {output_file}")
            print(f"   📁 {docs_file}")
            print(f"   ⚠️  Could not find UI Guidelines section markers in story-planner.md")
    else:
        print(f"✅ UI guidelines successfully generated:")
        print(f"   📁 {output_file}")
        print(f"   📁 {docs_file}")
        print(f"   ⚠️  story-planner.md not found")
    
except Exception as e:
    print(f"❌ Error generating UI guidelines: {str(e)}")
    sys.exit(1)
EOF
    
    if $PYTHON_CMD temp_ui_guideline_generator.py; then
        echo -e "  ${GREEN}✓${NC} UI guidelines successfully generated and updated in all locations"
    else
        echo -e "  ${RED}✗${NC} UI guideline generation failed"
    fi
    
    # Clean up temporary script
    rm -f temp_ui_guideline_generator.py
else
    echo -e "  ${DIM}Skipping UI guideline generation - Flutter screens not available.${NC}"
fi

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔄 Running Flutter setup...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Check if Flutter is available
if command -v flutter &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Running ${CYAN}flutter pub get${NC}..."
    flutter pub get
    echo
else
    echo -e "  ${YELLOW}⚠${NC} Flutter not found. Please run ${CYAN}flutter pub get${NC} manually."
    echo
fi

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔥 Setting up Firebase...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Check if Firebase setup script exists
if [ -f "scripts/firebase-setup.sh" ]; then
    echo -e "  ${GREEN}✓${NC} Running Firebase project setup..."
    echo -e "  ${DIM}Package Name: $new_package_name${NC}"
    echo -e "  ${DIM}Firebase Project ID: $firebase_project_id${NC}"
    echo -e "  ${DIM}Display Name: $display_name${NC}"
    echo
    
    # Make sure script is executable
    chmod +x scripts/firebase-setup.sh
    
    # Run Firebase setup with Firebase project ID (with dashes)
    if ./scripts/firebase-setup.sh "$firebase_project_id" "$display_name"; then
        echo -e "  ${GREEN}✓${NC} Firebase project setup completed!"
        echo
    else
        echo -e "  ${YELLOW}⚠${NC} Firebase setup encountered issues. You may need to run it manually later."
        echo -e "  ${DIM}Command: ./scripts/firebase-setup.sh $firebase_project_id \"$display_name\"${NC}"
        echo
    fi
    
    # firebase.json no longer needs project ID updates - FlutterFire handles Flutter configuration
    echo -e "  ${GREEN}✓${NC} firebase.json is properly configured for Firebase CLI"
else
    echo -e "  ${YELLOW}⚠${NC} Firebase setup script not found. Skipping Firebase setup."
    echo
fi

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔥 Setting up FlutterFire...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Check if FlutterFire setup script exists
if [ -f "scripts/flutterfire-setup.sh" ]; then
    echo -e "  ${GREEN}✓${NC} Running FlutterFire configuration..."
    echo -e "  ${DIM}Firebase Project ID: $firebase_project_id${NC}"
    echo -e "  ${DIM}Platforms: android,ios,web${NC}"
    echo
    
    # Make sure script is executable
    chmod +x scripts/flutterfire-setup.sh
    
    # Run FlutterFire setup with Firebase project ID (with dashes)
    if ./scripts/flutterfire-setup.sh "$firebase_project_id" "android,ios,web"; then
        echo -e "  ${GREEN}✓${NC} FlutterFire configuration completed!"
        echo
    else
        echo -e "  ${YELLOW}⚠${NC} FlutterFire setup encountered issues. You may need to run it manually later."
        echo -e "  ${DIM}Command: ./scripts/flutterfire-setup.sh $firebase_project_id android,ios,web${NC}"
        echo
    fi
else
    echo -e "  ${YELLOW}⚠${NC} FlutterFire setup script not found. Skipping FlutterFire setup."
    echo
fi

# echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
# echo -e "${BLUE}🤖 Setting up Serena MCP Server...${NC}"
# echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
# echo

# # Setup Serena MCP server for Claude Code
# if command -v claude &> /dev/null && command -v uvx &> /dev/null; then
#     echo -e "  ${GREEN}✓${NC} Adding Serena MCP server to Claude Code..."
#     claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant
#     echo -e "  ${GREEN}✓${NC} Serena MCP server configured successfully!"
#     echo
# else
#     echo -e "  ${RED}✗${NC} Claude Code or uvx not available. Skipping Serena MCP setup."
#     echo -e "  ${DIM}Please run manually: claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant${NC}"
#     echo
# fi

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔥 Setting up GitHub repository...${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Setup GitHub repository (we're already in the project directory)
echo -e "  ${GREEN}✓${NC} Setting up GitHub repository..."

# Check if GitHub setup script exists
if [ -f "scripts/github-setup.sh" ]; then
    echo -e "  ${GREEN}✓${NC} Running GitHub repository setup..."
    echo -e "  ${DIM}Project Name: $new_package_name${NC}"
    echo -e "  ${DIM}Description: $display_name Flutter application${NC}"
    echo
    
    # Make sure script is executable and fix line endings
    chmod +x scripts/github-setup.sh
    sed -i 's/\r$//' scripts/github-setup.sh 2>/dev/null || true
    
    # Run GitHub setup with camelCase project name and description
    if ./scripts/github-setup.sh "$camel_case_name" "$display_name Flutter application" "private"; then
        echo -e "  ${GREEN}✓${NC} GitHub repository setup completed!"
        echo
    else
        echo -e "  ${YELLOW}⚠${NC} GitHub setup encountered issues. You may need to run it manually later."
        echo -e "  ${DIM}Command: ./scripts/github-setup.sh $camel_case_name \"$display_name Flutter application\" private${NC}"
        echo
    fi
else
    echo -e "  ${YELLOW}⚠${NC} GitHub setup script not found. Skipping GitHub setup."
    echo
fi

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Success!${NC} Project customization completed"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "${DIM}Package name: '${NC}${YELLOW}flutter_basic_project${NC}${DIM}' → '${NC}${GREEN}$camel_case_name${NC}${DIM}'${NC}"
echo -e "${DIM}Firebase project ID: '${NC}${GREEN}$firebase_project_id${NC}${DIM}'${NC}"
echo -e "${DIM}Display name: '${NC}${GREEN}$display_name${NC}${DIM}'${NC}"
echo
echo -e "${CYAN}📋 What was set up:${NC}"
echo -e "  ${BOLD}✓${NC} Development environment verified/installed"
echo -e "  ${BOLD}✓${NC} Project package name customized"
echo -e "  ${BOLD}✓${NC} Flutter dependencies updated"
echo -e "  ${BOLD}✓${NC} Firebase project created and configured"
echo -e "  ${BOLD}✓${NC} FlutterFire integration completed"
echo -e "  ${BOLD}✓${NC} Firebase services ready (Auth, Firestore, Storage, Analytics, Crashlytics)"
echo -e "  ${BOLD}✓${NC} Project created in directory: ${CYAN}$new_package_name${NC}"
echo -e "  ${BOLD}✓${NC} GitHub repository created and code pushed"
echo
echo -e "${CYAN}📋 Next steps:${NC}"
echo -e "  ${BOLD}1.${NC} Your project is ready in: ${CYAN}$(pwd)${NC}"
echo -e "  ${BOLD}2.${NC} Initialize Firebase in your main.dart:"
echo -e "     ${DIM}import 'package:firebase_core/firebase_core.dart';${NC}"
echo -e "     ${DIM}import 'firebase_options.dart';${NC}"
echo -e "     ${DIM}await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);${NC}"
echo -e "  ${BOLD}3.${NC} Run ${CYAN}flutter clean${NC} ${DIM}(clear cached files)${NC}"
echo -e "  ${BOLD}4.${NC} Test your application ${DIM}(flutter run)${NC}"
echo -e "  ${BOLD}5.${NC} Start coding with Claude Code! ${DIM}(claude code .)${NC}"
echo -e "  ${BOLD}6.${NC} Visit your GitHub repository: ${DIM}https://github.com/AppbuildchatClientApp/$camel_case_name${NC}"
echo
echo -e "${DIM}Your development environment is ready! 🚀${NC}"

echo -e "${DIM}Opening the new project directory${NC}"
sleep 2
code ../$camel_case_name