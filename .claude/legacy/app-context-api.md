---
allowed-tools: Task, Write
argument-hint: [directory-path]
description: Analyze Flutter app source code and extract features, screens, and metadata into structured YAML
---

# App Context Analysis

Analyze the Flutter application source code at path: ${1:-.} (defaulting to current directory if not specified).

## Variables

PROMPT: "Analyze the Flutter application source code in the lib folder at path: ${1:-.} and extract features, screens, and metadata into structured YAML format. Focus on detailed code analysis, precise widget positioning, actual color tracing, and API endpoint extraction.

IMPORTANT: Analyze ONLY the lib folder contents. Do not analyze any files outside of the lib directory.

## Your Task

Perform an extremely detailed analysis of this Flutter/Dart application focusing on the lib folder only. Output results in structured YAML format with these specific requirements:

### 1. Features Detection
- Identify major features by analyzing:
  - Service classes (auth_service.dart, api_service.dart, etc.)
  - Controllers and providers
  - Screen groupings and naming patterns
  - Business logic implementations in functions/ directories

### 2. Detailed Screen Analysis
For each screen file (*_screen.dart), provide:

**Widget Positioning**:
- Exact placement in layout hierarchy (e.g., 'First child in Column widget', 'Positioned at top of Stack')
- Container relationships and nesting
- Specific positioning within parent widgets

**Color Analysis**:
- Trace color definitions to actual values (DO NOT use abstract names like 'primary' or 'AppColors.blue')
- Follow color references through theme files and color definitions
- Report actual color names: 'Blue', 'Red', 'Green', 'Orange', 'Purple', etc.
- If hex values are found, convert to color names (e.g., #FF0000 = 'Red')

**Button Analysis**:
- Exact location within screen layout
- Precise positioning (e.g., 'Bottom center, 16px padding from edges')
- Action performed when pressed (function names and what they do)
- Size and styling details

**Widget Details**:
- All widgets used with their specific properties
- Layout structure (Row, Column, Stack, etc.)
- Padding, margins, and spacing values
- Text content and styling

### 3. App Metadata
Extract from pubspec.yaml:
- App name, description, version
- Package name if available
- Infer app category from features

### 4. Code Analysis Requirements
- Scan all .dart files in lib/ directory only
- Look for patterns:
  - `class *Screen extends` for screens
  - HTTP calls (http.post, dio.post, etc.)
  - Widget usage in build methods
  - Navigation routes and relationships
  - Color definitions in theme files
  - Function calls and actions

## Output Format

Structure response in valid YAML following this schema:

```yaml
# App Context Analysis Results
app_metadata:
  name: \"app_name\"
  description: \"description\"
  category: \"category_type\"
  package_name: \"package_name\"
  version: \"version\"
  flutter_sdk: \"sdk_version\"
  platforms:
    - android
    - ios

features:
  - feature_id: \"feature_name\"
    name: \"Feature Display Name\"
    description: \"What this feature does\"
    confidence: 0.95
    screens:
      - name: \"ScreenName\"
        path: \"lib/path/to/screen.dart\"
        widgets_used:
          - \"Widget1\"
          - \"Widget2\"
        layout_structure:
          - \"Scaffold > Column > [widgets]\"
        ui_elements:
          - type: \"button\"
            location: \"Bottom center of screen\"
            position: \"Last child in Column, inside Container with 16px padding\"
            color: \"Blue\"  # Actual color name, not abstract reference
            text: \"Login\"
            action: \"Calls signInWithEmail() function\"
            size: \"Full width, 48px height\"
          - type: \"text_field\"
            location: \"Top section of form\"
            position: \"Second child in Column after title\"
            color: \"Grey\"  # Border color
            placeholder: \"Enter email\"
            validation: \"Email format validation\"
          - type: \"text\"
            location: \"Screen header\"
            position: \"First child in Column\"
            color: \"Black\"
            content: \"Welcome Back\"
            style: \"24px, bold\"
    endpoints:
      - method: \"POST\"
        path: \"/api/auth/login\"
        description: \"User authentication\"
    services:
      - \"AuthService\"
    models:
      - \"User\"
    functions:
      - \"signInWithEmail\"

analysis_summary:
  total_screens_found: X
  total_features_detected: X
  total_endpoints_found: X
  total_models_found: X
  total_functions_found: X
  code_files_analyzed: X
  confidence_level: \"high\"

analysis_notes:
  - \"Color tracing performed through theme definitions\"
  - \"Widget positioning analyzed from build method structure\"
  - \"Button actions traced through onPressed callbacks\"
```

## Critical Requirements:
1. **Color Tracing**: Follow all color references to find actual color values. Convert hex codes to color names.
2. **Exact Positioning**: Describe precise widget placement in layout hierarchy.
3. **Real Actions**: Identify actual function calls and their purposes.
4. **lib Folder Only**: Do not analyze any files outside the lib directory.
5. **File Output**: Write the complete YAML results to app_context.yml file.

Return comprehensive analysis with real color names and exact UI positioning details."

## Agent

### Step 1: Analyze with nano-agent
@nano-agent-grok-4-fast PROMPT

### Step 2: Create YAML File
After receiving the nano-agent analysis results, create the app_context.yml file using the Write tool. Extract the structured YAML content from the nano-agent analysis and save it to app_context.yml with proper formatting.

The YAML file should include:
- app_metadata with name, version, description from pubspec.yaml
- features array with detailed screen analysis
- ui_elements with exact positioning and real color names
- analysis_summary with counts and statistics
- endpoints and services detected

Use Write tool to create the complete app_context.yml file based on the nano-agent analysis results.