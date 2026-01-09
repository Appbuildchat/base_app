# Ollama OpenAI Compatibility

## Quick Start

```python
from openai import OpenAI

client = OpenAI(
    base_url='http://localhost:11434/v1',
    api_key='ollama',  # required but unused
)

response = client.chat.completions.create(
    model="llama2",  # or any model you have pulled
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.choices[0].message.content)
```

## Setup

1. Download and install Ollama
2. Pull a model: `ollama pull llama2`
3. Ollama runs on `http://localhost:11434`

## Available Models

Any model you have pulled with Ollama can be used. Popular options:
- llama2
- mistral
- codellama
- mixtral
- deepseek-coder
- phi
- neural-chat
- starling-lm
- orca-mini

To pull a model: `ollama pull <model_name>`

## API Endpoint

- Base URL: `http://localhost:11434/v1`
- Chat Completions: `/v1/chat/completions`

## cURL Example

```bash
curl http://localhost:11434/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "llama2",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Hello!"}
        ]
    }'
```

## Features Support

✅ Supported:
- Chat completions
- Streaming responses
- System/user/assistant messages
- Multi-turn conversations

⏳ Future (under consideration):
- Embeddings API
- Function calling
- Vision support
- Logprobs

## Key Notes

1. API key is required by OpenAI client libraries but not used by Ollama (can be any string)
2. Model name should match exactly what you've pulled with `ollama pull`
3. Runs locally on port 11434
4. Experimental support - GitHub issues welcome

## Integration Examples

### Vercel AI SDK
```typescript
const openai = new OpenAI({
    baseURL: 'http://localhost:11434/v1',
    apiKey: 'ollama',
});
```

### Autogen
```python
config_list = [
    {
        "model": "codellama",
        "base_url": "http://localhost:11434/v1",
        "api_key": "ollama",
    }
]
```