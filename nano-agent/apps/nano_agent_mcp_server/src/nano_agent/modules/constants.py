"""
Central constants and configuration for the Nano Agent.

This module contains all shared constants, default values, and configuration
used across the nano agent codebase.
"""

# Default Model Configuration
DEFAULT_MODEL = "x-ai/grok-code-fast-1"  # X.ai's fast coding model
DEFAULT_PROVIDER = "openrouter"

# Available Models by Provider
AVAILABLE_MODELS = {
    "openrouter": [
        "x-ai/grok-code-fast-1",
        "openrouter/sonoma-sky-alpha",
        "x-ai/grok-4-fast",
        "qwen/qwen3-coder",
        "google/gemini-2.5-flash",
        "openai/gpt-5",
        "deepseek/deepseek-v3.1-terminus",
    ],
}

# Model Display Names and Descriptions
MODEL_INFO = {
    "x-ai/grok-code-fast-1": "Grok Code Fast 1 - X.ai's fast coding model",
    "openrouter/sonoma-sky-alpha": "Sonoma Sky Alpha - OpenRouter's experimental model",
    "x-ai/grok-4-fast": "Grok 4 Fast - X.ai's latest fast model",
    "qwen/qwen3-coder": "Qwen3 Coder - Alibaba's coding-focused model",
    "google/gemini-2.5-flash": "Gemini 2.5 Flash - Google's fast multimodal model",
    "openai/gpt-5": "GPT-5 - OpenAI's latest flagship model",
    "deepseek/deepseek-v3.1-terminus": "DeepSeek V3.1 Terminus - DeepSeek's advanced coding model",
}

# Provider API Key Requirements
PROVIDER_REQUIREMENTS = {
    "openrouter": "OPENROUTER_API_KEY",
}

# Agent Configuration
MAX_AGENT_TURNS = 20  # Maximum turns in agent loop
DEFAULT_TEMPERATURE = 0.2  # Temperature for agent responses
MAX_TOKENS = 4000  # Maximum tokens per response

# Tool Names
TOOL_READ_FILE = "read_file"
TOOL_LIST_DIRECTORY = "list_directory"
TOOL_WRITE_FILE = "write_file"
TOOL_GET_FILE_INFO = "get_file_info"
TOOL_EDIT_FILE = "edit_file"

# Available Tools List
AVAILABLE_TOOLS = [
    TOOL_READ_FILE,
    TOOL_LIST_DIRECTORY,
    TOOL_WRITE_FILE,
    TOOL_GET_FILE_INFO,
    TOOL_EDIT_FILE,
]

# Demo Configuration
DEMO_PROMPTS = [
    ("List all files in the current directory", DEFAULT_MODEL),
    (
        "Create a file called demo.txt with the content 'Hello from Nano Agent!'",
        DEFAULT_MODEL,
    ),
    ("Read the file demo.txt and tell me what it says", DEFAULT_MODEL),
]

# System Prompts
NANO_AGENT_SYSTEM_PROMPT = """You are a helpful autonomous agent that can perform file operations.

Your capabilities:
1. Read files to understand their contents
2. List directories to explore project structure
3. Write files to create or modify content
4. Get detailed file information

When given a task:
1. First understand what needs to be done
2. Explore the relevant files and directories
3. Complete the task step by step
4. Verify your work

Be thorough but concise. Always verify files exist before trying to read them.
When writing files, ensure the content is correct before saving.

If asked about general information, respond and do not use any tools.
"""

# Error Messages
ERROR_NO_API_KEY = "{} environment variable is not set"
ERROR_PROVIDER_NOT_SUPPORTED = (
    "Provider '{}' not supported. Available providers: openrouter"
)
ERROR_FILE_NOT_FOUND = "Error: File not found: {}"
ERROR_NOT_A_FILE = "Error: Path is not a file: {}"
ERROR_DIR_NOT_FOUND = "Error: Directory not found: {}"
ERROR_NOT_A_DIR = "Error: Path is not a directory: {}"

# Success Messages
SUCCESS_FILE_WRITE = "Successfully wrote {} bytes to {}"
SUCCESS_FILE_EDIT = "updated"
SUCCESS_AGENT_COMPLETE = "Agent completed successfully in {:.2f}s"

# Version Info
VERSION = "1.0.0"
