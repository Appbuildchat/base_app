---
allowed-tools: Bash(python:*)
description: Consolidates all analysis files from output-app-context/ into a single comprehensive markdown document using Python script
---

# App Context Collector Agent

**MISSION:** Execute Python script to collect and consolidate all analysis files from `output-app-context/` directory into a single comprehensive markdown document.

## 🎯 EXECUTION COMMAND

```bash
python .claude/agents/app-context/collector.py
```

## 📋 SCRIPT FUNCTIONALITY

The Python script automatically:
1. **Scans Directory**: Checks `output-app-context/` for the 5 expected analysis files
2. **Processes Files in Order**:
   - `1.core-analysis.md`
   - `2.entity-analysis.md`
   - `3.function-analysis.md`
   - `4.presentation-analysis.md`
   - `5.theme-analysis.md`
3. **Generates Consolidated File**: Creates `output-app-context/consolidated-analysis.md` with:
   - Header with generation timestamp
   - Table of contents
   - All content from source files in order
   - Clear section separators between files
   - Error handling for missing files

## ✅ OUTPUT
- **File**: `output-app-context/consolidated-analysis.md`
- **Content**: Complete consolidation of all 5 analysis files
- **Format**: Structured markdown with TOC and section breaks
- **Status**: Console output shows processing results and any warnings