# OpenAI Agent SDK Lifecycle Hooks

## Overview
The OpenAI Agent SDK provides lifecycle hooks to tap into various events during agent execution. There are two main types of hooks:
- **RunHooks**: For monitoring the entire run lifecycle
- **AgentHooks**: For monitoring a specific agent's lifecycle

## RunHooks

`RunHooks` is used when running an agent with `Runner.run()` and allows you to monitor:
- Agent start/end events
- Tool execution start/end
- Agent handoffs

### RunHooksBase Class

```python
from agents.lifecycle import RunHooksBase
from agents import Agent, RunContextWrapper

class MyRunHooks(RunHooksBase):
    async def on_agent_start(self, context: RunContextWrapper, agent: Agent) -> None:
        """Called before the agent is invoked. Called each time the current agent changes."""
        pass
    
    async def on_agent_end(self, context: RunContextWrapper, agent: Agent, output: Any) -> None:
        """Called when the agent produces a final output."""
        pass
    
    async def on_handoff(self, context: RunContextWrapper, from_agent: Agent, to_agent: Agent) -> None:
        """Called when a handoff occurs."""
        pass
    
    async def on_tool_start(self, context: RunContextWrapper, agent: Agent, tool: Tool) -> None:
        """Called before a tool is invoked."""
        pass
    
    async def on_tool_end(self, context: RunContextWrapper, agent: Agent, tool: Tool, result: str) -> None:
        """Called after a tool is invoked."""
        pass
```

## AgentHooks

`AgentHooks` is set on a specific agent instance via `agent.hooks` and allows monitoring that specific agent:

### AgentHooksBase Class

```python
from agents.lifecycle import AgentHooksBase

class MyAgentHooks(AgentHooksBase):
    async def on_start(self, context: RunContextWrapper, agent: Agent) -> None:
        """Called before the agent is invoked."""
        pass
    
    async def on_end(self, context: RunContextWrapper, agent: Agent, output: Any) -> None:
        """Called when the agent produces a final output."""
        pass
    
    async def on_handoff(self, context: RunContextWrapper, agent: Agent, source: Agent) -> None:
        """Called when the agent is being handed off to."""
        pass
    
    async def on_tool_start(self, context: RunContextWrapper, agent: Agent, tool: Tool) -> None:
        """Called before a tool is invoked."""
        pass
    
    async def on_tool_end(self, context: RunContextWrapper, agent: Agent, tool: Tool, result: str) -> None:
        """Called after a tool is invoked."""
        pass
```

## Usage Example

### Using RunHooks with Runner

```python
from agents import Agent, Runner
from agents.lifecycle import RunHooksBase

class LoggingRunHooks(RunHooksBase):
    async def on_tool_start(self, context, agent, tool):
        print(f"Starting tool: {tool.name}")
    
    async def on_tool_end(self, context, agent, tool, result):
        print(f"Tool {tool.name} completed with result: {result[:100]}")

# Create agent
agent = Agent(name="MyAgent", tools=[...])

# Run with hooks
result = await Runner.run(
    agent,
    "Your prompt here",
    hooks=LoggingRunHooks()
)
```

### Using AgentHooks on Agent

```python
from agents import Agent
from agents.lifecycle import AgentHooksBase

class LoggingAgentHooks(AgentHooksBase):
    async def on_tool_start(self, context, agent, tool):
        print(f"Agent {agent.name} starting tool: {tool.name}")
    
    async def on_tool_end(self, context, agent, tool, result):
        print(f"Agent {agent.name} tool {tool.name} result: {result[:100]}")

# Create agent with hooks
agent = Agent(
    name="MyAgent",
    tools=[...],
    hooks=LoggingAgentHooks()
)
```

## Key Points

1. **Async Methods**: All hook methods are async and must be defined with `async def`
2. **Context Object**: The `RunContextWrapper` provides access to run context and metadata
3. **Tool Object**: Contains tool name, arguments, and other metadata
4. **Result Truncation**: Consider truncating long results in logging to avoid overwhelming output
5. **Error Handling**: Hooks should handle their own errors to avoid disrupting the agent execution

## Integration with Rich Logging

For rich console output with panels and formatted JSON:

```python
from rich.console import Console
from rich.panel import Panel
from rich.syntax import Syntax
import json

console = Console()

class RichLoggingHooks(RunHooksBase):
    async def on_tool_start(self, context, agent, tool):
        # Format tool arguments as JSON
        args_preview = json.dumps(tool.arguments, indent=2)[:100]
        
        # Display in rich panel
        console.print(Panel(
            Syntax(args_preview, "json", theme="monokai"),
            title=f"🔧 Tool: {tool.name}",
            border_style="cyan"
        ))
    
    async def on_tool_end(self, context, agent, tool, result):
        # Display result in panel
        result_preview = result[:100] + "..." if len(result) > 100 else result
        console.print(Panel(
            result_preview,
            title=f"✅ Tool Result: {tool.name}",
            border_style="green"
        ))
```

## Full Example

```python
import asyncio
import random
from typing import Any

from pydantic import BaseModel

from agents import Agent, RunContextWrapper, RunHooks, Runner, Tool, Usage, function_tool


class ExampleHooks(RunHooks):
    def __init__(self):
        self.event_counter = 0

    def _usage_to_str(self, usage: Usage) -> str:
        return f"{usage.requests} requests, {usage.input_tokens} input tokens, {usage.output_tokens} output tokens, {usage.total_tokens} total tokens"

    async def on_agent_start(self, context: RunContextWrapper, agent: Agent) -> None:
        self.event_counter += 1
        print(
            f"### {self.event_counter}: Agent {agent.name} started. Usage: {self._usage_to_str(context.usage)}"
        )

    async def on_agent_end(self, context: RunContextWrapper, agent: Agent, output: Any) -> None:
        self.event_counter += 1
        print(
            f"### {self.event_counter}: Agent {agent.name} ended with output {output}. Usage: {self._usage_to_str(context.usage)}"
        )

    async def on_tool_start(self, context: RunContextWrapper, agent: Agent, tool: Tool) -> None:
        self.event_counter += 1
        print(
            f"### {self.event_counter}: Tool {tool.name} started. Usage: {self._usage_to_str(context.usage)}"
        )

    async def on_tool_end(
        self, context: RunContextWrapper, agent: Agent, tool: Tool, result: str
    ) -> None:
        self.event_counter += 1
        print(
            f"### {self.event_counter}: Tool {tool.name} ended with result {result}. Usage: {self._usage_to_str(context.usage)}"
        )

    async def on_handoff(
        self, context: RunContextWrapper, from_agent: Agent, to_agent: Agent
    ) -> None:
        self.event_counter += 1
        print(
            f"### {self.event_counter}: Handoff from {from_agent.name} to {to_agent.name}. Usage: {self._usage_to_str(context.usage)}"
        )


hooks = ExampleHooks()

###


@function_tool
def random_number(max: int) -> int:
    """Generate a random number up to the provided max."""
    return random.randint(0, max)


@function_tool
def multiply_by_two(x: int) -> int:
    """Return x times two."""
    return x * 2


class FinalResult(BaseModel):
    number: int


multiply_agent = Agent(
    name="Multiply Agent",
    instructions="Multiply the number by 2 and then return the final result.",
    tools=[multiply_by_two],
    output_type=FinalResult,
)

start_agent = Agent(
    name="Start Agent",
    instructions="Generate a random number. If it's even, stop. If it's odd, hand off to the multiplier agent.",
    tools=[random_number],
    output_type=FinalResult,
    handoffs=[multiply_agent],
)


async def main() -> None:
    user_input = input("Enter a max number: ")
    await Runner.run(
        start_agent,
        hooks=hooks,
        input=f"Generate a random number between 0 and {user_input}.",
    )

    print("Done!")


if __name__ == "__main__":
    asyncio.run(main())
"""
$ python examples/basic/lifecycle_example.py

Enter a max number: 250
### 1: Agent Start Agent started. Usage: 0 requests, 0 input tokens, 0 output tokens, 0 total tokens
### 2: Tool random_number started. Usage: 1 requests, 148 input tokens, 15 output tokens, 163 total tokens
### 3: Tool random_number ended with result 101. Usage: 1 requests, 148 input tokens, 15 output tokens, 163 total token
### 4: Handoff from Start Agent to Multiply Agent. Usage: 2 requests, 323 input tokens, 30 output tokens, 353 total tokens
### 5: Agent Multiply Agent started. Usage: 2 requests, 323 input tokens, 30 output tokens, 353 total tokens
### 6: Tool multiply_by_two started. Usage: 3 requests, 504 input tokens, 46 output tokens, 550 total tokens
### 7: Tool multiply_by_two ended with result 202. Usage: 3 requests, 504 input tokens, 46 output tokens, 550 total tokens
### 8: Agent Multiply Agent ended with output number=202. Usage: 4 requests, 714 input tokens, 63 output tokens, 777 total tokens
Done!

"""
```