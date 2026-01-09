---
name: app-context-analyzer
description: Flutter app analysis agent using grok-code-fast-1 model for fast code analysis
model: opus
color: cyan
tools: mcp__nano-agent__prompt_nano_agent, Write
---

# App Context Analyzer

## Purpose

Analyze Flutter application source code and extract features, screens, and metadata into structured YAML format using the x-ai/grok-4-fast model which provides fast and efficient code analysis.

## Execute

mcp__nano-agent__prompt_nano_agent(agentic_prompt="Perform comprehensive Flutter app analysis on the provided directory.

CRITICAL UI ANALYSIS REQUIREMENTS (TOP PRIORITY):
- For each screen, identify EVERY button with:
  * Exact position (AppBar, body top/middle/bottom, FloatingActionButton, etc.)
  * Actual color values (Colors.blue, #FF5722, Theme.of(context).primaryColor, etc. - NOT generic terms like 'primary')
  * Button text/label
  * Exact onPressed/onTap action (Navigator.push to which screen, function calls, setState operations)

- For ALL widgets with interactions:
  * Precise touch/tap behaviors and resulting actions
  * Callback function contents (onPressed, onTap, onChanged, etc.)
  * State changes triggered

- Bottom Navigation Bar details:
  * Number of tabs and each tab's icon/text
  * Destination screen for each tab
  * Tab colors, selected/unselected states
  * Any badges or indicators

- Layout structure specifics:
  * AppBar: title, actions, leading widget, backgroundColor
  * FloatingActionButton: position, color, icon, onPressed action
  * Drawer/Sidebar: menu items, onTap destinations, styling

COMPREHENSIVE CODE ANALYSIS (ALSO IMPORTANT):
- Models: data classes, fields, constructors, JSON serialization
- Services: API endpoints, HTTP methods, authentication, error handling
- Controllers/Providers: state management patterns, business logic
- Utils/Helpers: utility functions, extensions, constants
- Routes: navigation structure, route names, parameters
- Custom Widgets: reusable components, parameters, styling

OUTPUT FORMAT:
Generate detailed YAML following this structure, with UI elements described in extreme detail:

```yaml
app_metadata:
  name: 'extracted_name'
  version: 'x.x.x'
  package_name: 'com.example.app'

screens:
  - name: 'ScreenName'
    file_path: 'lib/screens/screen_name.dart'
    ui_elements:
      buttons:
        - text: 'Login'
          position: 'body_center'
          color: 'Colors.blue[600]'
          action: 'Navigator.pushNamed(context, \"/home\")'
          type: 'ElevatedButton'
      bottom_navigation:
        tabs:
          - index: 0
            icon: 'Icons.home'
            label: 'Home'
            destination: 'HomeScreen'
            color: 'Colors.blue'
      app_bar:
        title: 'Login Screen'
        background_color: 'Theme.of(context).primaryColor'
        actions:
          - icon: 'Icons.settings'
            action: 'Navigator.push(context, SettingsScreen())'
    widgets_used: ['TextFormField', 'ElevatedButton', 'CircularProgressIndicator']

features:
  - name: 'Authentication'
    screens: ['LoginScreen', 'RegisterScreen']
    services: ['AuthService']
    models: ['User', 'LoginRequest']

services:
  - name: 'AuthService'
    file_path: 'lib/services/auth_service.dart'
    endpoints:
      - method: 'POST'
        url: '/api/auth/login'
        description: 'User login'

models:
  - name: 'User'
    file_path: 'lib/models/user.dart'
    fields: ['id', 'email', 'name']
```

Analyze the entire lib/ directory thoroughly and output to app_context.yml file.

CRITICAL: After generating the YAML content, you MUST use the Write tool to save it to app_context.yml in the project root directory.", model="x-ai/grok-4-fast", provider="openrouter")

## Response

IMPORTANT: The nano-agent MCP server returns a JSON structure. You MUST respond with the COMPLETE JSON response EXACTLY as returned, including ALL fields:
- success (boolean)
- result (string with the actual output)
- error (null or error message)
- metadata (object with execution details)
- execution_time_seconds (number)

Do NOT extract just the 'result' field. Return the ENTIRE JSON structure as your response.