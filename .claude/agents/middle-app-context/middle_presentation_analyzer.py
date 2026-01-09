#!/usr/bin/env python3
"""
Presentation Analyzer - Simple 4-function structure
Analyzes Flutter presentation layer using GPT-5 with incremental file saving.
"""

import glob
import sys
from pathlib import Path

# Add project root to Python path
project_root = Path(__file__).parent.parent.parent.parent
sys.path.append(str(project_root))

from config.call_llm import call_llm
import subprocess

def load_dart_files_from_list():
    """Load all dart file paths from output/list/*.md files"""
    base_dir = Path("/home/test1/aas/AAS_0.2.0/flutter-base-project")
    list_dir = base_dir / "output" / "middle-list"

    # Find all domain files (no need to regenerate, they exist)
    domain_files = glob.glob(str(list_dir / "*-presentation-files.md"))

    # Extract all dart file paths
    dart_files = []
    for domain_file in domain_files:
        with open(domain_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line.startswith('- `') and line.endswith('`'):
                    dart_path = line[3:-1]  # Remove "- `" and "`"
                    full_path = str(base_dir / dart_path)  # Make absolute path
                    dart_files.append(full_path)

    return dart_files

def analyze_dart_file(dart_file_path):
    """Analyze a single Dart file using GPT-5"""
    # Read dart file content directly (dart_file_path is already full path)
    with open(dart_file_path, 'r', encoding='utf-8') as f:
        dart_content = f.read()

    # Prepare detailed GPT-5 prompt
    prompt = f"""Analyze this Flutter Dart file following this EXACT format:

**Screen Purpose**:
- Main functionality and user goals
- Screen role in app navigation flow

**Layout Structure**:
- **Scaffold Configuration**:
  - Background Color: [Hex code]
  - Safe Area: [Enabled/Disabled]
  - Floating Action Button: [Position/None]
- **AppBar Details**:
  - Title: "[Exact text]"
  - Title Color: [Hex code]
  - Background Color: [Hex code]
  - Leading Icon: [Type/None]
  - Actions: [List of actions with positions]
  - Elevation: [Value]
- **Body Layout**:
  - Root Widget: [Container/Column/ScrollView/etc.]
  - Padding: [Top, Right, Bottom, Left in pixels]
  - Alignment: [MainAxisAlignment/CrossAxisAlignment]

**UI Components (Top to Bottom)**:

**1. [Component Name] - Position: [Exact position description]**
- Widget Type: [TextField/Button/Text/Image/etc.]
- Size: [Width x Height in pixels or constraints]
- Position: [Absolute/Relative positioning details]
- Background Color: [Hex code]
- Border: [Color, width, radius]
- Text Content: "[Exact text shown]"
- Text Style:
  - Font Size: [px/sp]
  - Font Weight: [400/500/700/etc.]
  - Color: [Hex code]
  - Alignment: [Left/Center/Right]
- Margins: [Top, Right, Bottom, Left in pixels]
- Padding: [Top, Right, Bottom, Left in pixels]

[Continue same detailed format for each component]

**Interactive Elements & Behaviors**:
- **[Button/Tap Target Name]**:
  - Trigger: [onPressed/onTap/gesture]
  - Action: [Exact function called or behavior]
  - Navigation: [Screen destination with route]
  - Visual Feedback: [Ripple/Color change/Animation]
  - Enabled State: [Always/Conditional]

**Form Elements** (if applicable):
- **[Input Field Name]**:
  - Input Type: [Text/Email/Password/Number]
  - Validation Rules: [Required/Format/Length]
  - Error Display: [Position and styling]
  - Helper Text: [Content and position]

**Navigation Flows from This Screen**:
```
[Current Screen]
  -> [Action 1] -> [Destination Screen 1]
  -> [Action 2] -> [Destination Screen 2]
  -> [Action 3] -> [Back/Close/Exit]
```

**State Management**:
- Loading States: [Visual indicators and positions]
- Error States: [Error display methods and styling]
- Success States: [Success feedback and transitions]

**Accessibility Features**:
- Screen Reader Labels: [Semantic labels used]
- Touch Target Sizes: [Minimum 48x48dp compliance]
- Color Contrast: [WCAG compliance notes]

**Business Logic & Functions**:
- **API Integration**:
  - Service Calls: [List API/repository functions called]
  - Data Models: [Entity/model classes used]
  - Request/Response Handling: [How data is processed]
- **State Management**:
  - Providers Used: [Provider classes and their purposes]
  - State Variables: [Local state management with setState]
  - State Updates: [When and how state changes occur]
- **Firebase Integration**:
  - Auth Functions: [Firebase Auth usage]
  - Firestore Operations: [Database read/write operations]
  - Storage Operations: [File upload/download if any]
- **Navigation Logic**:
  - Route Management: [GoRouter usage, route parameters]
  - Deep Linking: [URL handling, route guards]
  - Navigation Guards: [Auth checks, role-based access]
- **Form Processing**:
  - Validation Logic: [Form validation functions used]
  - Data Transformation: [Input processing, formatting]
  - Submission Handling: [Form submit functions]
- **Utility Functions**:
  - Helper Functions: [Utility functions imported and used]
  - Extensions: [Custom extensions applied]
  - Constants/Enums: [Static values and enumerations used]

STRICTLY FORBIDDEN - DO NOT INCLUDE:
- Any summary, executive summary, or overview
- Total counts, statistics, domain overviews
- Pattern summaries, conclusions, insights
- General observations or categorizations
- "Key findings" or "Overall analysis"
- Any section not specified in the format above

ONLY provide pure detailed analysis of THIS specific file following the exact format above.

File: {dart_file_path}

Dart file content:
```dart
{dart_content}
```"""

    # Call GPT-5
    messages = [
        {"role": "system", "content": "You are a Flutter UI analysis expert. Provide detailed technical analysis of Dart files without any summaries or overviews."},
        {"role": "user", "content": prompt}
    ]

    response = call_llm(messages, "gpt-5-mini")
    return response.choices[0].message.content

def analyze_widget_file(dart_file_path):
    """Analyze a single Widget file using GPT-5"""
    # Read dart file content directly (dart_file_path is already full path)
    with open(dart_file_path, 'r', encoding='utf-8') as f:
        dart_content = f.read()

    # Prepare detailed GPT-5 prompt for widget analysis
    prompt = f"""Analyze this Flutter Widget file following this EXACT format:

**Widget Purpose**:
- Widget functionality and reuse context
- Parameters and customization options

**Component Structure**:
- Root Widget: [Container/Column/Row/Stack/etc.]
- Widget Hierarchy: [Parent-child structure description]
- Size Constraints: [Width/Height constraints or flex behavior]
- Layout Behavior: [How children are arranged]

**Styling & Appearance**:
- Colors: [Primary/background/accent colors used with hex codes]
- Typography: [Text styles, font sizes, weights if any]
- Spacing: [Margins/padding patterns in pixels]
- Decorations: [Borders/shadows/gradients/etc.]
- Visual Effects: [Animations/transitions if any]

**Customization Properties**:
- Required Parameters: [List with types and purposes]
- Optional Parameters: [List with default values]
- Callbacks: [onTap/onChange/onSubmit/etc. with descriptions]
- Configuration Options: [Style variants/modes available]

**State Management**:
- State Variables: [Internal state if StatefulWidget]
- State Updates: [When and how state changes]
- External Dependencies: [Providers/services used]

**Usage Context**:
- Where this widget is typically used
- Integration patterns with other widgets
- Reusability across different screens

**Implementation Details**:
- Build Method Structure: [Key implementation points]
- Performance Considerations: [Optimization patterns used]
- Platform Differences: [iOS/Android specific handling if any]

STRICTLY FORBIDDEN - DO NOT INCLUDE:
- Any summary, executive summary, or overview
- Total counts, statistics, domain overviews
- Pattern summaries, conclusions, insights
- General observations or categorizations
- "Key findings" or "Overall analysis"
- Any section not specified in the format above

ONLY provide pure detailed analysis of THIS specific widget file following the exact format above.

File: {dart_file_path}

Dart file content:
```dart
{dart_content}
```"""

    # Call gpt-5-mini
    messages = [
        {"role": "system", "content": "You are a Flutter Widget analysis expert. Provide detailed technical analysis of Flutter widget files without any summaries or overviews."},
        {"role": "user", "content": prompt}
    ]

    response = call_llm(messages, "gpt-5-mini")
    return response.choices[0].message.content

def save_analysis_to_md(dart_file_path, analysis):
    """Save analysis result to markdown file"""
    base_dir = Path("/home/test1/aas/AAS_0.2.0/flutter-base-project")
    output_file = base_dir / "output-middle-app-context" / "4.presentation-analysis.md"

    # Ensure output directory exists
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # Prepare content
    file_name = Path(dart_file_path).name
    content = f"""
    #### {file_name}

    {analysis}

    ---

    """

    # Append to file
    with open(output_file, 'a', encoding='utf-8') as f:
        f.write(content)

def is_screen_file(dart_file_path):
    """Detect if a dart file is a screen or widget"""
    file_name = Path(dart_file_path).name.lower()

    # Check if it's a screen file
    screen_indicators = ['screen.dart', 'page.dart', '_screen.dart', '_page.dart']
    for indicator in screen_indicators:
        if file_name.endswith(indicator):
            return True

    # Check if it's in screens directory
    if '/screens/' in dart_file_path or '/presentation/' in dart_file_path:
        # Additional check: if contains 'widget' in name, it's likely a widget
        if 'widget' in file_name:
            return False
        return True

    # Default to widget if uncertain
    return False

def main():
    """Main execution function"""
    # First, generate the latest screen list
    print("📋 Generating latest presentation file list...")
    subprocess.run([sys.executable, str(Path(__file__).parent / "middle_screen_list_generator.py")], check=True)

    base_dir = Path("/home/test1/aas/AAS_0.2.0/flutter-base-project")
    output_file = base_dir / "output-middle-app-context" / "4.presentation-analysis.md"

    # Initialize output file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# Presentation Layer Analysis\n\n")

    # Load all dart files
    dart_files = load_dart_files_from_list()

    # Process each dart file
    for i, dart_file in enumerate(dart_files, 1):
        try:
            file_name = Path(dart_file).name
            print(f"🤖 Analyzing {file_name} ({i}/{len(dart_files)})...")

            # Detect file type and use appropriate analysis function
            if is_screen_file(dart_file):
                print(f"   📱 Detected as Screen file")
                analysis = analyze_dart_file(dart_file)
            else:
                print(f"   🧩 Detected as Widget file")
                analysis = analyze_widget_file(dart_file)

            save_analysis_to_md(dart_file, analysis)
            print(f"✅ Completed {file_name}")
        except Exception as e:
            print(f"❌ Error with {Path(dart_file).name}: {e}")

    print(f"\n🎉 Analysis completed! Results saved to: {output_file}")

if __name__ == "__main__":
    main()