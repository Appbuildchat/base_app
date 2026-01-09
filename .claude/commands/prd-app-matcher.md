**SEQUENTIAL EXECUTION REQUIRED** - Execute comprehensive PRD analysis and generate implementation guide for Flutter app development.

⚠️ **CRITICAL**: This command orchestrates a 3-stage analysis process that MUST be executed sequentially. DO NOT run agents in parallel.

## 🔄 Stage 1: Analyze PRD Requirements
**FIRST STEP ONLY** - Run @prd-app-matcher/prd-analyzer and wait for completion:
- ⛔ **STOP HERE** - Do not proceed until Stage 1 is complete

## 🔄 Stage 2: Identify Unimplemented Features
**AFTER Stage 1 completes** - Run @prd-app-matcher/flutter-feature-checker:
- ⛔ **STOP HERE** - Do not proceed until Stage 2 is complete

## 🔄 Stage 3: Generate Implementation Guide
**AFTER Stage 2 completes** - Run @prd-app-matcher/implementation-guide-generator:

## ✅ Final Step
Display summary of all generated files in output/ directory.

---
## 🚨 EXECUTION RULES
1. **ONE AGENT AT A TIME** - Never run multiple agents simultaneously
2. **WAIT FOR COMPLETION** - Each stage must finish before starting next
3. **CHECK OUTPUT FILES** - Verify each stage creates its expected output file
4. **NO PARALLEL EXECUTION** - This will cause dependency failures