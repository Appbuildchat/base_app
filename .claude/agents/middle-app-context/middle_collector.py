#!/usr/bin/env python3
"""
App Context Collector
Consolidates all analysis files from output-middle-app-context/ into a single comprehensive markdown document.
"""

import os
from datetime import datetime
from pathlib import Path

def main():
    # Define paths
    base_dir = Path("/home/test1/aas/AAS_0.2.0/flutter-base-project")
    input_dir = base_dir / "output-middle-app-context"
    output_file = input_dir / "app-context.md"

    # Define expected files in order
    expected_files = [
        "1.core-analysis.md",
        "2.entity-analysis.md",
        "3.function-analysis.md",
        "4.presentation-analysis.md",
        "5.theme-analysis.md"
    ]

    # Check if input directory exists
    if not input_dir.exists():
        print(f"❌ Error: Directory {input_dir} does not exist")
        return False

    print(f"🔍 Scanning {input_dir} for analysis files...")

    # Prepare consolidated content
    consolidated_content = []
    consolidated_content.append("# Consolidated App Context Analysis")
    consolidated_content.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    consolidated_content.append("")

    # Generate table of contents
    consolidated_content.append("## Table of Contents")
    toc_entries = []

    for i, filename in enumerate(expected_files, 1):
        file_path = input_dir / filename
        if file_path.exists():
            # Extract title from filename
            title = filename.replace('.md', '').replace('-', ' ').title()
            toc_entries.append(f"{i}. [{title}](#{filename.replace('.md', '').replace('.', '').replace('-', '-')})")

    consolidated_content.extend(toc_entries)
    consolidated_content.append("")
    consolidated_content.append("---")
    consolidated_content.append("")

    # Process each file
    files_processed = 0
    for filename in expected_files:
        file_path = input_dir / filename

        if file_path.exists():
            print(f"📄 Processing {filename}...")

            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read().strip()

                # Add section header
                title = filename.replace('.md', '').replace('-', ' ').title()
                consolidated_content.append(f"## {title}")
                consolidated_content.append(f"*Source: {filename}*")
                consolidated_content.append("")

                # Add file content
                consolidated_content.append(content)
                consolidated_content.append("")
                consolidated_content.append("---")
                consolidated_content.append("")

                files_processed += 1

            except Exception as e:
                print(f"⚠️  Warning: Could not read {filename}: {e}")
                consolidated_content.append(f"## {title}")
                consolidated_content.append(f"*Error reading {filename}: {e}*")
                consolidated_content.append("")
                consolidated_content.append("---")
                consolidated_content.append("")
        else:
            print(f"⚠️  Warning: {filename} not found")

    if files_processed == 0:
        print("❌ No analysis files found to consolidate")
        return False

    # Write consolidated file
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(consolidated_content))

        print(f"✅ Successfully consolidated {files_processed} files")
        print(f"📝 Output: {output_file}")
        print(f"📊 Total lines: {len(consolidated_content)}")

        return True

    except Exception as e:
        print(f"❌ Error writing consolidated file: {e}")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)