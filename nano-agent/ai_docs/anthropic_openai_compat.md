# Anthropic OpenAI SDK Compatibility

## Quick Start

```python
from openai import OpenAI

client = OpenAI(
    api_key="ANTHROPIC_API_KEY",  # Your Anthropic API key
    base_url="https://api.anthropic.com/v1/"  # Anthropic's API endpoint
)

response = client.chat.completions.create(
    model="claude-3-haiku-20240307",  # Anthropic model name
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Who are you?"}
    ],
)

print(response.choices[0].message.content)
```

## Available Models
- claude-3-opus-20240229
- claude-3-sonnet-20240229
- claude-3-haiku-20240307
- claude-3-5-sonnet-20241022
- claude-3-5-haiku-20241022

## Key Differences from OpenAI
1. System messages are hoisted and concatenated at the beginning
2. `strict` parameter for function calling is ignored
3. Audio input not supported
4. Prompt caching not supported via OpenAI SDK (use native Anthropic SDK)
5. Rate limits follow Anthropic's standard limits

## Supported Features
- ✅ Chat completions
- ✅ Streaming
- ✅ Function/tool calling (without strict mode)
- ✅ max_tokens / max_completion_tokens
- ✅ temperature (0-1)
- ✅ top_p
- ✅ stop sequences
- ✅ Image inputs

## Ignored Parameters
- logprobs
- response_format
- presence_penalty
- frequency_penalty
- seed
- audio
- modalities

## Extended Thinking Support

```python
response = client.chat.completions.create(
    model="claude-3-opus-20240229",
    messages=...,
    extra_body={
        "thinking": {"type": "enabled", "budget_tokens": 2000}
    }
)
```

## Important Notes
- This compatibility layer is for testing and comparison, not production
- For full features (PDFs, citations, prompt caching), use native Anthropic SDK
- Most unsupported fields are silently ignored rather than producing errors