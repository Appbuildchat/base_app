from call_llm import call_llm

def generate_ui_guideline(screen_content: str) -> str:
    """
    Generate UI structural guidelines by analyzing Flutter screen code
    using GPT through the call_llm system.
    """
    messages = [
        {
            "role": "system",
            "content": """You are a UI architect creating a high-level structural guide for developers. 
            Your goal is to describe the *patterns, structure, and component composition* from the base screen code, so other developers (or an AI) can build new screens with a consistent style. 
            Focus on the architectural patterns, not literal values.
            Please respond entirely in English."""
        },
        {
            "role": "user",
            "content": f"""Your task is to analyze the provided Flutter code and create a high-level **structural and architectural guideline**. 
            The goal is to explain the *how* and *why* of the UI structure, so that new screens can be built consistently. 
            **Focus on patterns and conventions, not exact pixel values or sizes.**

            ## Base Screen File
            ```dart
            {screen_content}
            ```

            ## Requirements:
            Create a high-level guide explaining the structural patterns of the UI.

            ### 1. Screen Architecture
            - Describe the main building blocks of the screen (e.g., Header, Tab Bar, Content Area, Bottom Navigation).
            - Explain the purpose and general function of each block.
            - What is the overall layout flow (e.g., "Main axis is vertical, using a Column")?

            ### 2. Component Design Patterns
            - For major components like `_buildProductCard` or `_buildHeader`, describe their composition. What widgets are they made of (e.g., "A Card contains an Image, then a Column of Text widgets").
            - Describe the information hierarchy within components (e.g., "In a product card, the Title is most prominent, followed by Price, then Location").
            - Describe the characteristic **shape and style** of components. For example, mention if cards have **"rounded corners,"** if buttons are **"pill-shaped"** or **"rectangular,"** and if they contain elements like icons.

            ### 3. Reusable Conventions & Patterns
            - Based on the code, define a set of conventions for building new UI.
            - Example conventions: "Use a `GridView` to display lists of products." or "Screen-level filters should be placed below the main tab bar."
            - Summarize the key reusable patterns that another AI should follow for consistency.

            ## CRITICAL INSTRUCTIONS:
            - **FOCUS ON PATTERNS, NOT PIXELS:** Generalize the design. Instead of **"the radius is 20," say "cards have rounded corners."** Instead of "padding is 16," say "sections have consistent horizontal padding." This captures the *style* without needing the exact numbers.
            - **DESCRIBE THE 'WHY':** Explain the purpose of the structure (e.g., "A header is used for global actions and branding.").
            - **IGNORE COLORS:** Do not mention color information.
            """
        }
    ]

    # Use GPT model through call_llm case 5
    response = call_llm(messages, model_type="5")
    return response.choices[0].message.content