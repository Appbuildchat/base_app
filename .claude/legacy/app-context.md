---
allowed-tools: Bash(find:*), Bash(grep:*), Bash(cat:*), Bash(ls:*)
argument-hint: [directory-path]
description: Analyze Flutter app source code and extract features, screens, and metadata into structured YAML
---

# App Context Analysis

Analyze the Flutter application source code at path: ${1:-.} (defaulting to current directory if not specified).

## Current project structure
!`find ${1:-.} -type f -name "*.dart" | head -20`

## Check for pubspec.yaml
!`ls -la ${1:-.}/pubspec.yaml 2>/dev/null || echo "pubspec.yaml not found"`

## Sample of screens directory
!`ls -la ${1:-.}/lib/screens/ 2>/dev/null | head -10 || echo "No screens directory found"`

## Your Task

Perform a comprehensive analysis of this Flutter/Dart application and output the results in structured YAML format. Focus on extracting:

1. **Features Detection**:
   - Identify major features by analyzing:
     - Service classes (auth_service.dart, api_service.dart, etc.)
     - Controllers and providers
     - Screen groupings and naming patterns
     - Business logic implementations
   - For each feature, extract:
     - Associated screens with their file paths
     - UI widgets and components used
     - API endpoints (search for URL patterns, HTTP methods)
     - UI element types and descriptions

2. **App Metadata**:
   - Extract from pubspec.yaml:
     - App name
     - Description
     - Version
     - Package name (if available)
   - Infer app category from features and screens

3. **Code Analysis Approach**:
   - Scan all .dart files in lib/ directory
   - Look for patterns like:
     - `class *Screen extends` for screens
     - `http.post`, `dio.post`, etc. for API calls
     - Widget usage patterns in build methods
     - Navigation routes and screen relationships

## Output Format Requirements

Structure your response in **valid YAML** following this exact schema:

```yaml
# App Context Analysis Results
app_metadata:
  name: "extracted_app_name"
  description: "App description from pubspec or inferred"
  category: "e-commerce|social|productivity|finance|etc"
  package_name: "com.example.app"
  version: "1.0.0"
  flutter_sdk: ">=3.0.0"
  platforms:
    - android
    - ios

features:
  - feature_id: "auth"
    name: "User Authentication"
    description: "Handles user login, registration, and session management"
    confidence: 0.95  # How confident the analysis is about this feature
    screens:
      - name: "LoginScreen"
        path: "lib/screens/auth/login_screen.dart"
        widgets_used:
          - "TextFormField"
          - "ElevatedButton"
          - "CircularProgressIndicator"
      - name: "RegisterScreen"
        path: "lib/screens/auth/register_screen.dart"
        widgets_used:
          - "TextFormField"
          - "DatePicker"
    ui_elements:
      - type: "form"
        location: "LoginScreen"
        description: "Email and password input form"
      - type: "button"
        location: "LoginScreen"
        description: "Submit login credentials"
    endpoints:
      - method: "POST"
        path: "/api/auth/login"
        description: "User authentication endpoint"
      - method: "POST"
        path: "/api/auth/register"
        description: "New user registration"
    services:
      - "AuthService"
      - "TokenManager"
    models:
      - "User"
      - "AuthToken"

  - feature_id: "product_catalog"
    name: "Product Browsing"
    description: "Browse and search products"
    confidence: 0.88
    screens:
      - name: "ProductListScreen"
        path: "lib/screens/products/product_list_screen.dart"
        widgets_used:
          - "ListView"
          - "SearchBar"
          - "FilterChip"
    # ... additional feature details

# Summary statistics
analysis_summary:
  total_screens_found: 15
  total_features_detected: 8
  total_endpoints_found: 24
  total_models_found: 12
  code_files_analyzed: 145
  confidence_level: "high|medium|low"

# Potential issues or notes
analysis_notes:
  - "Some API endpoints inferred from string patterns"
  - "Feature grouping based on file organization"
  - "Unable to determine exact API base URL"
```

Important guidelines:
- Use ONLY information that can be extracted from the source code
- Include confidence scores when inference is involved
- Maintain valid YAML syntax throughout
- Use clear, descriptive names for features
- Include file paths relative to project root
- Group related screens under the same feature
- Extract actual widget names from import statements and usage

Begin the analysis now and output the results in the specified YAML format. Write that result to a app_context.yml file