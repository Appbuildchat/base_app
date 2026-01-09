import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")

openrouter_client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=OPENROUTER_API_KEY
)

def call_llm(messages: list[dict], model_type: str = "gpt-5"):
    match model_type:
        case "grok-4-fast-free":
            response = openrouter_client.chat.completions.create(
                model="x-ai/grok-4-fast:free",
                messages=messages,
                temperature=0
            )
            return response
        case "grok-code-fast":
            response = openrouter_client.chat.completions.create(
                model="x-ai/grok-code-fast-1",
                messages=messages,
                temperature=0
            )
            return response
        case "grok-4":
            response = openrouter_client.chat.completions.create(
                model="x-ai/grok-4",
                messages=messages,
                temperature=0
            )
            return response
        case "gemini-2.5-flash":
            response = openrouter_client.chat.completions.create(
                model="google/gemini-2.5-flash",
                messages=messages,
                temperature=0
            )
            return response
        case "gemini-2.5-pro":
            response = openrouter_client.chat.completions.create(
                model="google/gemini-2.5-pro",
                messages=messages,
                temperature=0
            )
            return response
        case "claude-opus-4.1":
            response = openrouter_client.chat.completions.create(
                model="anthropic/claude-opus-4.1",
                messages=messages,
                temperature=0
            )
            return response
        case "claude-sonnet-4":
            response = openrouter_client.chat.completions.create(
                model="anthropic/claude-sonnet-4",
                messages=messages,
                temperature=0
            )
            return response
        case "deepseek-chat-v3.1":
            response = openrouter_client.chat.completions.create(
                model="deepseek/deepseek-chat-v3.1",
                messages=messages,
                temperature=0
            )
            return response
        case "gpt-5":
            response = openrouter_client.chat.completions.create(
                model="openai/gpt-5",
                messages=messages,
                temperature=0
            )
            return response
        case "gpt-5-mini":
            response = openrouter_client.chat.completions.create(
                model="openai/gpt-5-mini",
                messages=messages,
                temperature=0
            )
            return response
        case "gpt-5-nano":
            response = openrouter_client.chat.completions.create(
                model="openai/gpt-5-nano",
                messages=messages,
                temperature=0
            )
            return response
        case "gpt-oss-120b":
            response = openrouter_client.chat.completions.create(
                model="openai/gpt-oss-120b",
                messages=messages,
                temperature=0
            )
            return response
        case "gpt-oss-20b":
            response = openrouter_client.chat.completions.create(
                model="openai/gpt-oss-20b",
                messages=messages,
                temperature=0
            )
            return response
        case "gpt-4.1-mini":
            response = openrouter_client.chat.completions.create(
                model="openai/gpt-4.1-mini",
                messages=messages,
                temperature=0
            )
            return response
        case _:
            raise ValueError(f"Unsupported model_type: {model_type}")