from call_llm import call_llm

def generate_flutter_screens(input_content: str) -> str:
    """
    Generate Flutter Dart screen files using Claude API
    based on the provided input content (PRD, app specifications, etc.).
    """
    dart_template = '''
    import 'package:flutter/material.dart';

    // Mock Data Classes
    class MockData {{
      // Generate realistic mock data based on the PRD
    }}

    // Main App with Bottom Navigation
    class GeneratedMainApp extends StatefulWidget {{
      @override
      _GeneratedMainAppState createState() => _GeneratedMainAppState();
    }}

    class _GeneratedMainAppState extends State<GeneratedMainApp> {{
      int _currentIndex = 0;
      
      final List<Widget> _screens = [
        GeneratedHomeScreen(),
        GeneratedListScreen(), 
        GeneratedDetailScreen(),
      ];

      @override
      Widget build(BuildContext context) {{
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: [
              // 3 navigation items with appropriate icons
            ],
          ),
        );
      }}
    }}

    // Screen 1: Main/Home Screen
    class GeneratedHomeScreen extends StatelessWidget {{
      @override
      Widget build(BuildContext context) {{
        return Scaffold(
          // Use Colors.blue, Colors.white, Colors.grey[600] etc.
        );
      }}
    }}

    // Screen 2: Secondary Screen
    class GeneratedListScreen extends StatelessWidget {{
      @override
      Widget build(BuildContext context) {{
        return Scaffold(
          // Use Colors.green, Colors.orange, Colors.grey[100] etc.
        );
      }}
    }}

    // Screen 3: Detail Screen
    class GeneratedDetailScreen extends StatelessWidget {{
      @override
      Widget build(BuildContext context) {{
        return Scaffold(
          // Use Colors.purple, Colors.red, Colors.grey[50] etc.
        );
      }}
    }}
    '''

    prompt = f"""
    [Objective]
    You are a senior Flutter developer and UI designer with expertise in creating beautiful, modern mobile app interfaces.
    Generate a single, complete Flutter Dart file containing 2-3 beautiful screen widgets based on the provided PRD/app specifications.

    [Critical Requirements]
    - Platform: Flutter mobile application
    - Output: Single .dart file with multiple screen widgets
    - Design Priority: Beautiful, intuitive, modern UI design
    - Colors: Use ONLY direct Flutter colors (Colors.blue, Colors.white, Colors.grey[600], etc.)
    - Spacing: Use direct values (padding: EdgeInsets.all(16.0), height: 120.0, etc.)
    - Mock Data: Include 1-2 realistic mock datasets
    - Universal: Must work for ANY app type/PRD
    - NO THEME IMPORTS: Do not import any theme files or custom colors

    [Analysis Instructions]
    FIRST, carefully analyze the provided PRD content to understand:
    1. What type of app is being designed (fitness, social, e-commerce, productivity, etc.)
    2. What are the 2-3 most important screens for this app
    3. What data/content should be displayed on each screen
    4. What UI components are needed (lists, cards, buttons, charts, etc.)
    5. What mock data would make the screens look realistic

    [Code Generation Requirements - MANDATORY]
    Generate a single Flutter .dart file with structure similar to this template:
    {dart_template}
    
    CRITICAL: Must include a main wrapper widget with BottomNavigationBar:
    
    // Main App with Bottom Navigation - REQUIRED
    class GeneratedMainApp extends StatefulWidget {{
      @override
      _GeneratedMainAppState createState() => _GeneratedMainAppState();
    }}
    
    class _GeneratedMainAppState extends State<GeneratedMainApp> {{
      int _currentIndex = 0;
      
      final List<Widget> _screens = [
        GeneratedHomeScreen(),
        GeneratedListScreen(), 
        GeneratedDetailScreen(),
      ];
    
      @override
      Widget build(BuildContext context) {{
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.secondary,
            items: [
              // 3 navigation items with appropriate icons
            ],
          ),
        );
      }}
    }}
    
    This GeneratedMainApp widget should be the main entry point that main.dart can use directly.

    [Design Guidelines - CRITICAL]
    - Use gradients, shadows, rounded corners for modern look
    - Create visual hierarchy with different text sizes and colors
    - Use cards and containers to organize content
    - Add proper spacing and padding for clean layout
    - Include icons and visual elements (use Icons.* from Flutter)
    - Make it look like a real, polished app
    - NO overlapping widgets - everything should be properly laid out
    - COLORS: Use Colors.blue, Colors.white, Colors.grey[600], Colors.black, Colors.green[400], etc.
    - NEVER use AppColors.anything or custom theme colors
    - Direct padding values: EdgeInsets.all(16.0), EdgeInsets.symmetric(horizontal: 20.0)
    - Direct sizes: height: 120.0, width: double.infinity, etc.

    [Universal Adaptation Rules]
    - If fitness app: show stats, progress, activities
    - If social app: show posts, profiles, interactions
    - If e-commerce: show products, cart, categories
    - If productivity: show tasks, calendar, progress
    - Always include appropriate mock data for the app type
    - Make screens contextually relevant to the app's purpose

    [Output Format]
    Return ONLY the complete Flutter .dart file code, nothing else.
    The code should be production-ready and immediately usable.
    
    IMPORTANT: 
    - The file MUST include the GeneratedMainApp widget with BottomNavigationBar as the main entry point
    - This widget should allow navigation between all the generated screens
    - Use ONLY Flutter's built-in colors: Colors.blue, Colors.white, Colors.grey[600], etc.
    - Do NOT import any theme files or use AppColors.anything
    - Only import: 'package:flutter/material.dart'

    [Input Content - PRD/App Specifications]
    {input_content}
    """

    messages = [
        {
            "role": "user",
            "content": prompt
        }
    ]
    
    response = call_llm(messages, "sonnet4")
    return response.content[0].text