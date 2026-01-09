import os
from dotenv import load_dotenv
from openai import OpenAI
from anthropic import Anthropic

load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")

openai_client = OpenAI(api_key=OPENAI_API_KEY)
anthropic_client = Anthropic(api_key=ANTHROPIC_API_KEY)

def call_llm(messages: list[dict], model_type: str = "5"):
    match model_type:
        case "5":
            response = openai_client.chat.completions.create(
                model="gpt-5-2025-08-07",
                messages=messages,
                #temperature=0
            )
            return response
        case "4.1mini":
            response = openai_client.chat.completions.create(
                model="gpt-4.1-mini-2025-04-14",
                messages=messages,
                temperature=0
            )
            return response
        case "sonnet4":
            response = anthropic_client.messages.create(
                model="claude-sonnet-4-20250514",
                max_tokens=8000,
                messages=messages
            )
            return response
        case _:
            raise ValueError(f"Unsupported model_type: {model_type}")
