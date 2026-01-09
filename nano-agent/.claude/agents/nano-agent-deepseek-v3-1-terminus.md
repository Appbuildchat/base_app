---
name: nano-agent-deepseek-v3-1-terminus
description: A nano agent that can be used to execute a prompt using the deepseek/deepseek-v3.1-terminus model.
model: opus
color: purple
tools: mcp__nano-agent__prompt_nano_agent
---

# Nano Agent

## Purpose

Using the incoming prompt as is with no changes, use the nano-agent mcp server to execute the prompt.

## Execute

mcp__nano-agent__prompt_nano_agent(agentic_prompt=PROMPT, model="deepseek/deepseek-v3.1-terminus", provider="openrouter")

## Response

IMPORTANT: The nano-agent MCP server returns a JSON structure. You MUST respond with the COMPLETE JSON response EXACTLY as returned, including ALL fields:
- success (boolean)
- result (string with the actual output)
- error (null or error message)
- metadata (object with execution details)
- execution_time_seconds (number)

Do NOT extract just the 'result' field. Return the ENTIRE JSON structure as your response.