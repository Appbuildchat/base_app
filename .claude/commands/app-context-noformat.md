---
allowed-tools: Bash(find:*), Bash(grep:*), Bash(cat:*), Bash(ls:*)
description: Analyze Flutter app presentation layer (UI screens) in lib/domain/*/presentation folders
---

**SEQUENTIAL EXECUTION REQUIRED** - Execute comprehensive Flutter app context analysis across 5 specialized domains in order.

🔄 **SEQUENTIAL AGENT ORCHESTRATION** - Run all 5 agents one by one to prevent resource conflicts.

## 🚀 Stage 1: Core Architecture Analysis
**Run @middle-app-context/middle-core-analyzer sequentially:**
- Input: lib/main.dart, lib/core/, routing, configuration files
- Output: `output-middle-app-context/1.core-analysis.md`
- **⏳ WAIT FOR COMPLETION** before proceeding to Stage 2

## 🚀 Stage 2: Entity & Model Analysis
**Run @middle-app-context/middle-entitiy-analyzer sequentially:**
- Input: lib/domain/*/entities/, lib/domain/*/models/, data classes
- Output: `output-middle-app-context/2.entity-analysis.md`
- **⏳ WAIT FOR COMPLETION** before proceeding to Stage 3

## 🚀 Stage 3: Business Logic Analysis
```bash
python .claude/agents/middle-app-context/middle_function_analyzer.py
```
- **⏳ WAIT FOR COMPLETION** before proceeding to Stage 4

## 🚀 Stage 4: Presentation Layer Analysis
```bash
python .claude/agents/middle-app-context/middle_presentation_analyzer.py
```
- **⏳ WAIT FOR COMPLETION** before proceeding to Stage 5

## 🚀 Stage 5: Theme & Design System Analysis
**Run @middle-app-context/middle-theme-analyzer sequentially:**
- Input: Theme files, colors, spacing, design tokens, style definitions
- Output: `output-middle-app-context/5.theme-analysis.md`


---
## 🚨 EXECUTION RULES
1. **SEQUENTIAL EXECUTION REQUIRED** - Run agents one by one to prevent resource conflicts and file race conditions
2. **WAIT FOR COMPLETION** - Each stage must complete before starting the next to ensure data integrity
3. **VERIFY OUTPUT FILES** - Ensure each agent creates its expected output file in `output-middle-app-context/`
4. **SPECIALIZED ANALYSIS** - Each agent focuses on its domain expertise for accurate results
5. **COMPREHENSIVE COVERAGE** - Combined analysis covers entire Flutter app architecture
6. **AVOID RESOURCE CONFLICTS** - Sequential execution prevents LLM API rate limits and system overload

