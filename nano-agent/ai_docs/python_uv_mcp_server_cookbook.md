# Python + UV Model Context Protocol (MCP) Server Cookbook

## Table of Contents
1. [Introduction](#introduction)
2. [Project Setup with UV](#project-setup-with-uv)
3. [FastMCP Fundamentals](#fastmcp-fundamentals)
4. [Building MCP Tools](#building-mcp-tools)
5. [Creating MCP Resources](#creating-mcp-resources)
6. [Implementing MCP Prompts](#implementing-mcp-prompts)
7. [Advanced Features](#advanced-features)
8. [Testing and Debugging](#testing-and-debugging)
9. [Deployment Strategies](#deployment-strategies)
10. [Best Practices](#best-practices)

## Introduction

The Model Context Protocol (MCP) is an open standard that enables seamless communication between AI applications and data sources. MCP servers act as bridges, exposing tools, resources, and prompts that LLMs can leverage to provide richer, more contextual responses.

### Core Concepts
- **Tools**: Functions that LLMs can execute (with side effects)
- **Resources**: Data endpoints that provide context (read-only)
- **Prompts**: Reusable templates for LLM interactions
- **Transport**: Communication layer (stdio, SSE, Streamable HTTP)

## Project Setup with UV

UV is Astral's ultra-fast Python package manager that simplifies MCP server development with its modern approach to dependency management and virtual environments.

### Initial Setup

```bash
# Install UV (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create a new MCP server project
uv init my-mcp-server --lib
cd my-mcp-server

# Set Python version (MCP supports 3.10+)
echo "3.10" > .python-version

# Add MCP dependency
uv add "mcp[cli]"
```

### Project Structure

```
my-mcp-server/
├── .python-version      # Python version pin
├── pyproject.toml       # Project configuration
├── uv.lock             # Locked dependencies
├── src/
│   └── my_mcp_server/
│       ├── __init__.py
│       └── server.py   # Main server implementation
└── tests/
    └── test_server.py
```

### pyproject.toml Configuration

```toml
[project]
name = "my-mcp-server"
version = "0.1.0"
description = "A modern MCP server built with FastMCP"
readme = "README.md"
requires-python = ">=3.10"
dependencies = [
    "mcp>=1.12.4",
    "httpx>=0.28.0",      # For API calls
    "pydantic>=2.11.0",   # For data validation
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
    "ruff>=0.5.0",
]

[build-system]
requires = ["uv>=0.8.6"]
build-backend = "uv"

[tool.uv]
dev-dependencies = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
]
```

## FastMCP Fundamentals

FastMCP is the high-level Python API for building MCP servers. It uses decorators and type hints to automatically generate protocol-compliant implementations.

### Basic Server Setup

```python
from mcp.server.fastmcp import FastMCP
from typing import Optional
from contextlib import asynccontextmanager
from collections.abc import AsyncIterator

# Create server instance
mcp = FastMCP(
    name="MyMCPServer",
    instructions="A powerful MCP server for data processing and analysis"
)

# Optional: Add lifespan management for resource initialization
@asynccontextmanager
async def server_lifespan(server: FastMCP) -> AsyncIterator[dict]:
    """Initialize resources on startup, cleanup on shutdown."""
    # Startup
    db_connection = await initialize_database()
    api_client = await setup_api_client()
    
    try:
        yield {
            "db": db_connection,
            "api": api_client
        }
    finally:
        # Shutdown
        await db_connection.close()
        await api_client.close()

mcp = FastMCP(
    name="MyMCPServer",
    lifespan=server_lifespan
)
```

### Running the Server

```python
if __name__ == "__main__":
    # Default stdio transport
    mcp.run()
    
    # Or specify transport explicitly
    # mcp.run(transport="streamable-http")
```

## Building MCP Tools

Tools are functions that LLMs can invoke to perform actions or computations. They should be idempotent when possible and include clear documentation.

### Basic Tools

```python
from mcp.server.fastmcp import FastMCP, Context
from typing import Optional, Literal
from pydantic import BaseModel, Field

mcp = FastMCP("ToolsExample")

@mcp.tool()
def calculate_compound_interest(
    principal: float,
    rate: float,
    time: int,
    frequency: Literal["annual", "monthly", "daily"] = "annual"
) -> float:
    """Calculate compound interest with configurable compounding frequency.
    
    Args:
        principal: Initial investment amount
        rate: Annual interest rate (as percentage, e.g., 5 for 5%)
        time: Investment period in years
        frequency: Compounding frequency
    """
    frequencies = {"annual": 1, "monthly": 12, "daily": 365}
    n = frequencies[frequency]
    rate_decimal = rate / 100
    
    amount = principal * (1 + rate_decimal/n) ** (n * time)
    return round(amount, 2)
```

### Tools with Context

```python
@mcp.tool()
async def process_data_with_progress(
    data_url: str,
    format: Literal["json", "csv", "xml"],
    ctx: Context
) -> dict:
    """Process data from URL with progress reporting.
    
    The Context parameter is automatically injected by FastMCP.
    """
    await ctx.info(f"Starting data processing from {data_url}")
    
    try:
        # Report progress
        await ctx.report_progress(0.2, 1.0, "Downloading data...")
        data = await download_data(data_url)
        
        await ctx.report_progress(0.5, 1.0, "Parsing data...")
        parsed = await parse_data(data, format)
        
        await ctx.report_progress(0.8, 1.0, "Analyzing...")
        results = await analyze_data(parsed)
        
        await ctx.report_progress(1.0, 1.0, "Complete!")
        await ctx.info(f"Processed {len(parsed)} records")
        
        return results
        
    except Exception as e:
        await ctx.error(f"Processing failed: {str(e)}")
        raise
```

### Structured Output Tools

```python
from pydantic import BaseModel, Field
from typing import List

class AnalysisResult(BaseModel):
    """Structured analysis output."""
    summary: str = Field(description="Executive summary")
    metrics: dict[str, float] = Field(description="Key metrics")
    recommendations: List[str] = Field(description="Action items")
    confidence: float = Field(ge=0, le=1, description="Confidence score")

@mcp.tool()
def analyze_business_data(
    revenue: List[float],
    costs: List[float],
    period: Literal["monthly", "quarterly", "yearly"]
) -> AnalysisResult:
    """Perform business analysis and return structured insights."""
    
    total_revenue = sum(revenue)
    total_costs = sum(costs)
    profit = total_revenue - total_costs
    margin = (profit / total_revenue * 100) if total_revenue > 0 else 0
    
    return AnalysisResult(
        summary=f"{period.capitalize()} analysis shows {margin:.1f}% profit margin",
        metrics={
            "total_revenue": total_revenue,
            "total_costs": total_costs,
            "profit": profit,
            "margin_percentage": margin,
            "average_revenue": total_revenue / len(revenue)
        },
        recommendations=[
            "Optimize operational costs" if margin < 20 else "Maintain cost efficiency",
            "Explore revenue growth opportunities" if margin < 30 else "Scale operations",
            "Review pricing strategy" if margin < 10 else "Consider market expansion"
        ],
        confidence=0.85
    )
```

## Creating MCP Resources

Resources provide read-only data access to LLMs. They use URI patterns and can be static or dynamic.

### Static Resources

```python
@mcp.resource("config://app/settings")
def get_app_settings() -> str:
    """Provide application configuration."""
    return json.dumps({
        "version": "1.0.0",
        "features": {
            "api_enabled": True,
            "rate_limit": 1000,
            "cache_ttl": 3600
        },
        "supported_formats": ["json", "xml", "csv"]
    }, indent=2)

@mcp.resource("docs://api/reference")
def get_api_documentation() -> str:
    """Provide API reference documentation."""
    return """
    # API Reference
    
    ## Authentication
    Use Bearer token in Authorization header.
    
    ## Endpoints
    - GET /api/v1/data - Retrieve data
    - POST /api/v1/process - Process data
    - DELETE /api/v1/cache - Clear cache
    """
```

### Dynamic Resources with Templates

```python
import httpx
from datetime import datetime

@mcp.resource("data://metrics/{metric_type}/{date}")
async def get_metrics(metric_type: str, date: str) -> str:
    """Fetch metrics for a specific type and date.
    
    URI pattern: data://metrics/{metric_type}/{date}
    Example: data://metrics/revenue/2024-01-15
    """
    # Parse and validate date
    try:
        metric_date = datetime.fromisoformat(date)
    except ValueError:
        return json.dumps({"error": "Invalid date format. Use YYYY-MM-DD"})
    
    # Fetch metrics (example with mock data)
    metrics = {
        "type": metric_type,
        "date": date,
        "value": 42000.50,
        "change": "+5.2%",
        "trend": "increasing"
    }
    
    return json.dumps(metrics, indent=2)

@mcp.resource("github://repo/{owner}/{repo}")
async def get_github_info(owner: str, repo: str) -> str:
    """Fetch GitHub repository information."""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"https://api.github.com/repos/{owner}/{repo}",
            headers={"Accept": "application/vnd.github.v3+json"}
        )
        
        if response.status_code == 200:
            data = response.json()
            return json.dumps({
                "name": data["name"],
                "description": data["description"],
                "stars": data["stargazers_count"],
                "language": data["language"],
                "open_issues": data["open_issues_count"]
            }, indent=2)
        else:
            return json.dumps({"error": f"Repository {owner}/{repo} not found"})
```

## Implementing MCP Prompts

Prompts are reusable templates that guide LLM interactions. They can return simple strings or structured message sequences.

### Simple Prompts

```python
@mcp.prompt(title="Code Review Assistant")
def code_review_prompt(
    language: str,
    code: str,
    focus_areas: str = "security,performance,readability"
) -> str:
    """Generate a comprehensive code review prompt."""
    return f"""Please review the following {language} code:

```{language}
{code}
```

Focus on these areas: {focus_areas}

Provide:
1. Overall assessment
2. Specific issues found
3. Suggestions for improvement
4. Security considerations
5. Performance optimizations
"""

@mcp.prompt(title="Data Analysis")
def analyze_data_prompt(
    data_description: str,
    analysis_type: Literal["descriptive", "diagnostic", "predictive"],
    output_format: str = "report"
) -> str:
    """Create a data analysis prompt."""
    prompts = {
        "descriptive": "Summarize the main characteristics and patterns",
        "diagnostic": "Identify root causes and relationships",
        "predictive": "Forecast trends and future outcomes"
    }
    
    return f"""Analyze the following data:
{data_description}

Analysis Type: {analysis_type}
Task: {prompts[analysis_type]}

Deliver the results as a {output_format} including:
- Key findings
- Statistical insights
- Visualizations recommendations
- Action items
"""
```

### Structured Message Prompts

```python
from mcp.server.fastmcp.prompts import base

@mcp.prompt(title="Interactive Debugging Session")
def debug_session(
    error_message: str,
    stack_trace: str,
    context: str = ""
) -> list[base.Message]:
    """Create an interactive debugging conversation."""
    return [
        base.UserMessage(f"I'm encountering this error: {error_message}"),
        base.UserMessage(f"Stack trace:\n{stack_trace}"),
        base.UserMessage(f"Context: {context}" if context else ""),
        base.AssistantMessage(
            "I'll help you debug this issue. Let me analyze the error and stack trace."
        ),
        base.AssistantMessage(
            "First, can you tell me what you were trying to accomplish when this error occurred?"
        ),
    ]
```

## Advanced Features

### Authentication and Security

```python
from mcp.server.auth.provider import TokenVerifier, AccessToken
from mcp.server.auth.settings import AuthSettings
from pydantic import AnyHttpUrl

class CustomTokenVerifier(TokenVerifier):
    """Implement custom token verification logic."""
    
    async def verify_token(self, token: str) -> AccessToken | None:
        # Validate token with your auth provider
        if await self.validate_with_provider(token):
            return AccessToken(
                token=token,
                scopes=["read", "write"],
                expires_at=datetime.now().timestamp() + 3600
            )
        return None
    
    async def validate_with_provider(self, token: str) -> bool:
        # Implement actual validation logic
        # Example: verify JWT, check with OAuth provider, etc.
        return True  # Placeholder

# Create authenticated server
mcp = FastMCP(
    "SecureServer",
    token_verifier=CustomTokenVerifier(),
    auth=AuthSettings(
        issuer_url=AnyHttpUrl("https://auth.example.com"),
        resource_server_url=AnyHttpUrl("http://localhost:8000"),
        required_scopes=["read"]
    )
)
```

### Elicitation for User Input

```python
from pydantic import BaseModel, Field

class UserPreferences(BaseModel):
    """Schema for collecting user preferences."""
    theme: Literal["light", "dark", "auto"] = Field(
        default="auto",
        description="UI theme preference"
    )
    notifications: bool = Field(
        default=True,
        description="Enable notifications"
    )
    language: str = Field(
        default="en",
        description="Preferred language code"
    )

@mcp.tool()
async def configure_settings(ctx: Context) -> dict:
    """Configure application with user preferences."""
    
    # Request additional information from user
    result = await ctx.elicit(
        message="Let's configure your preferences",
        schema=UserPreferences
    )
    
    if result.action == "accept" and result.data:
        # Apply user preferences
        settings = {
            "theme": result.data.theme,
            "notifications": result.data.notifications,
            "language": result.data.language,
            "configured_at": datetime.now().isoformat()
        }
        
        await ctx.info(f"Settings configured: {settings}")
        return settings
    else:
        return {"status": "cancelled", "message": "Configuration cancelled by user"}
```

### Sampling (LLM Integration)

```python
from mcp.types import SamplingMessage, TextContent

@mcp.tool()
async def generate_content(
    topic: str,
    style: str,
    max_words: int,
    ctx: Context
) -> str:
    """Generate content using LLM sampling."""
    
    prompt = f"""Write a {style} article about {topic}.
    Maximum length: {max_words} words.
    Include relevant examples and maintain consistent tone."""
    
    # Request LLM generation
    result = await ctx.session.create_message(
        messages=[
            SamplingMessage(
                role="user",
                content=TextContent(type="text", text=prompt)
            )
        ],
        max_tokens=max_words * 2  # Rough token estimate
    )
    
    if result.content.type == "text":
        generated = result.content.text
        word_count = len(generated.split())
        
        await ctx.info(f"Generated {word_count} words on '{topic}'")
        return generated
    
    return "Generation failed"
```

## Testing and Debugging

### Development Tools

```bash
# Install MCP development server
uv run mcp dev src/my_mcp_server/server.py

# Test with dependencies
uv run mcp dev server.py --with pandas --with numpy

# Interactive testing with Inspector
uv run mcp dev server.py
```

### Unit Testing

```python
# tests/test_server.py
import pytest
from unittest.mock import AsyncMock, MagicMock
from my_mcp_server.server import mcp

@pytest.mark.asyncio
async def test_calculate_tool():
    """Test calculation tool."""
    # Direct function testing
    result = mcp._tool_handlers["calculate_compound_interest"](
        principal=1000,
        rate=5,
        time=10,
        frequency="annual"
    )
    assert result == 1628.89

@pytest.mark.asyncio
async def test_tool_with_context():
    """Test tool that uses context."""
    # Mock context
    mock_ctx = MagicMock()
    mock_ctx.info = AsyncMock()
    mock_ctx.report_progress = AsyncMock()
    
    # Test tool execution
    result = await mcp._tool_handlers["process_data"](
        data_url="http://example.com/data.json",
        format="json",
        ctx=mock_ctx
    )
    
    # Verify context methods were called
    mock_ctx.info.assert_called()
    mock_ctx.report_progress.assert_called()
```

### Integration Testing

```python
# tests/test_integration.py
import asyncio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

@pytest.mark.asyncio
async def test_server_integration():
    """Test full server integration."""
    server_params = StdioServerParameters(
        command="uv",
        args=["run", "python", "src/my_mcp_server/server.py"]
    )
    
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            # Initialize connection
            await session.initialize()
            
            # Test tools
            tools = await session.list_tools()
            assert len(tools.tools) > 0
            
            # Test tool execution
            result = await session.call_tool(
                "calculate_compound_interest",
                arguments={"principal": 1000, "rate": 5, "time": 10}
            )
            assert result.content[0].text == "1628.89"
```

## Deployment Strategies

### Claude Desktop Integration

```bash
# Quick install for Claude Desktop
uv run mcp install src/my_mcp_server/server.py --name "My Server"

# With environment variables
uv run mcp install server.py \
  --name "Production Server" \
  -v API_KEY=$API_KEY \
  -v DATABASE_URL=$DATABASE_URL
```

### Streamable HTTP Deployment

```python
# server.py with HTTP transport
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("HTTPServer", stateless_http=True)

# ... define tools, resources, prompts ...

if __name__ == "__main__":
    # Run as HTTP server
    mcp.run(
        transport="streamable-http",
        host="0.0.0.0",
        port=8000
    )
```

### Docker Deployment

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install UV
RUN pip install uv

# Copy project files
COPY pyproject.toml uv.lock ./
COPY src/ ./src/

# Install dependencies
RUN uv sync --frozen

# Run server
CMD ["uv", "run", "python", "src/my_mcp_server/server.py"]
```

### Multi-Server Deployment

```python
# multi_server.py
from starlette.applications import Starlette
from starlette.routing import Mount
import contextlib

# Import multiple MCP servers
from analytics_server import analytics_mcp
from data_server import data_mcp
from ml_server import ml_mcp

@contextlib.asynccontextmanager
async def lifespan(app: Starlette):
    async with contextlib.AsyncExitStack() as stack:
        await stack.enter_async_context(analytics_mcp.session_manager.run())
        await stack.enter_async_context(data_mcp.session_manager.run())
        await stack.enter_async_context(ml_mcp.session_manager.run())
        yield

app = Starlette(
    routes=[
        Mount("/analytics", analytics_mcp.streamable_http_app()),
        Mount("/data", data_mcp.streamable_http_app()),
        Mount("/ml", ml_mcp.streamable_http_app()),
    ],
    lifespan=lifespan
)
```

## Best Practices

### 1. Tool Design
- **Idempotency**: Tools should produce consistent results
- **Error Handling**: Always handle and report errors gracefully
- **Documentation**: Include clear docstrings with examples
- **Validation**: Use Pydantic models for input/output validation
- **Progress Reporting**: Report progress for long-running operations

### 2. Resource Patterns
- **URI Conventions**: Use consistent, semantic URI patterns
- **Caching**: Implement caching for expensive operations
- **Pagination**: Handle large datasets with pagination
- **Format Flexibility**: Support multiple output formats

### 3. Security
- **Input Validation**: Always validate and sanitize inputs
- **Authentication**: Implement proper token verification
- **Rate Limiting**: Protect against abuse
- **Secrets Management**: Never expose sensitive data in responses
- **Audit Logging**: Log all tool invocations and access

### 4. Performance
- **Async Operations**: Use async/await for I/O operations
- **Connection Pooling**: Reuse connections in lifespan
- **Lazy Loading**: Load resources only when needed
- **Streaming**: Use streaming for large responses

### 5. Development Workflow
```bash
# Development cycle
uv sync                    # Install dependencies
uv run ruff check .        # Lint code
uv run pytest             # Run tests
uv run mcp dev server.py  # Test interactively
uv run mcp install server.py  # Deploy to Claude
```

### 6. Error Messages
```python
@mcp.tool()
async def robust_tool(param: str, ctx: Context) -> dict:
    """Example of robust error handling."""
    try:
        # Validate input
        if not param:
            raise ValueError("Parameter cannot be empty")
        
        # Process
        result = await process(param)
        
        # Validate output
        if not result:
            await ctx.warning("No results found")
            return {"status": "no_data", "message": "No results available"}
        
        return {"status": "success", "data": result}
        
    except ValueError as e:
        await ctx.error(f"Validation error: {e}")
        return {"status": "error", "message": str(e)}
    except Exception as e:
        await ctx.error(f"Unexpected error: {e}")
        return {"status": "error", "message": "An unexpected error occurred"}
```

### 7. Monitoring and Observability
```python
from datetime import datetime
import json

@mcp.tool()
async def monitored_tool(data: dict, ctx: Context) -> dict:
    """Tool with built-in monitoring."""
    start_time = datetime.now()
    request_id = ctx.request_id
    
    await ctx.info(f"[{request_id}] Starting operation")
    
    try:
        # Log input
        await ctx.debug(f"[{request_id}] Input: {json.dumps(data)}")
        
        # Process
        result = await process_data(data)
        
        # Log success metrics
        duration = (datetime.now() - start_time).total_seconds()
        await ctx.info(f"[{request_id}] Completed in {duration:.2f}s")
        
        return result
        
    except Exception as e:
        # Log failure
        duration = (datetime.now() - start_time).total_seconds()
        await ctx.error(f"[{request_id}] Failed after {duration:.2f}s: {e}")
        raise
```

## Conclusion

Building modern MCP servers with Python and UV provides a powerful, efficient development experience. FastMCP's decorator-based approach combined with UV's fast dependency management creates an ideal environment for rapid MCP server development.

Key takeaways:
- Use UV for fast, reliable dependency management
- Leverage FastMCP's type hints for automatic schema generation
- Implement proper error handling and logging
- Follow security best practices
- Test thoroughly with MCP Inspector
- Deploy flexibly with multiple transport options

With these tools and practices, you can build robust, scalable MCP servers that seamlessly integrate with AI applications, providing rich context and capabilities to enhance LLM interactions.

## Additional Resources

- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Python SDK Documentation](https://github.com/modelcontextprotocol/python-sdk)
- [UV Documentation](https://docs.astral.sh/uv/)
- [Example MCP Servers](https://github.com/modelcontextprotocol/servers)
- [MCP Community Forum](https://github.com/modelcontextprotocol/discussions)