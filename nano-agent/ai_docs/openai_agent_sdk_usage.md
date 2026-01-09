# OpenAI Agent SDK Usage Tracking

## Overview
The OpenAI Agent SDK provides comprehensive token usage tracking through the `Usage` class. This allows monitoring of API costs and resource consumption during agent execution.

## Usage Class

```python
from agents import Usage
from dataclasses import dataclass, field

@dataclass
class Usage:
    requests: int = 0
    """Total requests made to the LLM API."""
    
    input_tokens: int = 0
    """Total input tokens sent, across all requests."""
    
    input_tokens_details: InputTokensDetails = field(
        default_factory=lambda: InputTokensDetails(cached_tokens=0)
    )
    """Details about the input tokens, matching responses API usage details."""
    
    output_tokens: int = 0
    """Total output tokens received, across all requests."""
    
    output_tokens_details: OutputTokensDetails = field(
        default_factory=lambda: OutputTokensDetails(reasoning_tokens=0)
    )
    """Details about the output tokens, matching responses API usage details."""
    
    total_tokens: int = 0
    """Total tokens sent and received, across all requests."""
    
    def add(self, other: "Usage") -> None:
        """Add another Usage object's counts to this one."""
        self.requests += other.requests if other.requests else 0
        self.input_tokens += other.input_tokens if other.input_tokens else 0
        self.output_tokens += other.output_tokens if other.output_tokens else 0
        self.total_tokens += other.total_tokens if other.total_tokens else 0
        self.input_tokens_details = InputTokensDetails(
            cached_tokens=self.input_tokens_details.cached_tokens
            + other.input_tokens_details.cached_tokens
        )
        self.output_tokens_details = OutputTokensDetails(
            reasoning_tokens=self.output_tokens_details.reasoning_tokens
            + other.output_tokens_details.reasoning_tokens
        )
```

## Accessing Usage in Lifecycle Hooks

Usage information is available through the `RunContextWrapper` in lifecycle hooks:

```python
from agents.lifecycle import RunHooksBase

class UsageTrackingHooks(RunHooksBase):
    def __init__(self):
        self.total_usage = Usage()
    
    async def on_agent_start(self, context, agent):
        # Access current usage
        current_usage = context.usage
        print(f"Requests so far: {current_usage.requests}")
        print(f"Input tokens: {current_usage.input_tokens}")
        print(f"Output tokens: {current_usage.output_tokens}")
        print(f"Total tokens: {current_usage.total_tokens}")
    
    async def on_agent_end(self, context, agent, output):
        # Track cumulative usage
        self.total_usage.add(context.usage)
        print(f"Total usage after agent: {self.total_usage.total_tokens} tokens")
    
    async def on_tool_start(self, context, agent, tool):
        # Usage is updated before each tool call
        print(f"Tokens before tool: {context.usage.total_tokens}")
    
    async def on_tool_end(self, context, agent, tool, result):
        # Usage is updated after tool execution
        print(f"Tokens after tool: {context.usage.total_tokens}")
```

## Token Details

### InputTokensDetails
- `cached_tokens`: Number of tokens retrieved from cache (reduces costs)

### OutputTokensDetails  
- `reasoning_tokens`: Number of tokens used for reasoning (GPT-5 models)

## Cost Calculation

You can calculate costs based on token usage:

```python
def calculate_cost(usage: Usage, model: str = "gpt-5-mini") -> float:
    """Calculate estimated cost based on token usage."""
    # Pricing per 1M tokens (example rates)
    pricing = {
        "gpt-5-mini": {
            "input": 0.15,   # $0.15 per 1M input tokens
            "output": 0.60,   # $0.60 per 1M output tokens
        },
        "gpt-5": {
            "input": 3.00,    # $3.00 per 1M input tokens
            "output": 15.00,  # $15.00 per 1M output tokens
        }
    }
    
    rates = pricing.get(model, pricing["gpt-5-mini"])
    
    input_cost = (usage.input_tokens / 1_000_000) * rates["input"]
    output_cost = (usage.output_tokens / 1_000_000) * rates["output"]
    
    return input_cost + output_cost
```

## Integration Example

```python
from agents import Agent, Runner, RunConfig
from agents.lifecycle import RunHooksBase

class TokenMonitor(RunHooksBase):
    def __init__(self):
        self.initial_tokens = 0
        self.tool_tokens = {}
    
    async def on_agent_start(self, context, agent):
        self.initial_tokens = context.usage.total_tokens
    
    async def on_tool_start(self, context, agent, tool):
        self.tool_tokens[tool.name] = context.usage.total_tokens
    
    async def on_tool_end(self, context, agent, tool, result):
        tokens_used = context.usage.total_tokens - self.tool_tokens[tool.name]
        print(f"Tool {tool.name} used {tokens_used} tokens")
    
    async def on_agent_end(self, context, agent, output):
        total_used = context.usage.total_tokens - self.initial_tokens
        print(f"Agent execution used {total_used} tokens total")
        print(f"Estimated cost: ${calculate_cost(context.usage):.4f}")

# Use with Runner
result = await Runner.run(
    agent,
    "Your prompt",
    hooks=TokenMonitor()
)

# Access final usage from result
print(f"Final usage: {result.usage}")
```

## Best Practices

1. **Monitor Cached Tokens**: Cached tokens reduce costs significantly
2. **Track Per-Tool Usage**: Identify which tools consume the most tokens
3. **Set Token Limits**: Implement guards against excessive token usage
4. **Log Usage Metrics**: Store usage data for analysis and optimization
5. **Alert on High Usage**: Set thresholds for cost alerts

## Token Optimization Tips

1. **Use Smaller Models**: GPT-5-mini for simple tasks
2. **Optimize Prompts**: Shorter, clearer prompts reduce input tokens
3. **Limit Output Length**: Use max_tokens settings appropriately
4. **Cache Responses**: Reuse common responses when possible
5. **Batch Operations**: Combine multiple operations when feasible