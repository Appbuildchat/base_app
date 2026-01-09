#!/usr/bin/env python3
import glob
from pathlib import Path
from collections import defaultdict
import os

def main():
    # Create output directory if it doesn't exist
    output_dir = "output/middle-core-list"
    os.makedirs(output_dir, exist_ok=True)

    # Find all core files by category (excluding themes)
    categories = defaultdict(lambda: {"files": []})

    # Define core file patterns (exclude themes)
    core_patterns = {
        "router": "lib/core/router/**/*.dart",
        "shell": "lib/core/shell/**/*.dart",
        "widgets": "lib/core/widgets/**/*.dart",
        "notification": "lib/core/notification/**/*.dart",
        "image_picker": "lib/core/image_picker/**/*.dart",
        "providers": "lib/core/providers/**/*.dart",
        "utilities": ["lib/core/validators.dart", "lib/core/result.dart", "lib/core/app_error_code.dart", "lib/core/error_page.dart"]
    }

    # Process each category
    for category_name, pattern in core_patterns.items():
        if category_name == "utilities":
            # Handle utilities as individual files
            for file_path in pattern:
                if os.path.exists(file_path):
                    categories[category_name]["files"].append(file_path)
        else:
            # Handle as glob pattern
            files = glob.glob(pattern, recursive=True)
            categories[category_name]["files"].extend(sorted(files))

    # Generate category-separated files
    for category_name, data in categories.items():
        if not data["files"]:
            continue

        output_file = f"{output_dir}/{category_name}-core-files.md"

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(f"# {category_name.title()} Core Files\n\n")
            f.write(f"## File List ({len(data['files'])} files)\n\n")

            for file_path in data["files"]:
                f.write(f"- `{file_path}`\n")

        print(f"Created {output_file} with {len(data['files'])} files")

    total_files = sum(len(data["files"]) for data in categories.values())
    print(f"\nTotal core files catalogued: {total_files}")
    print(f"Categories created: {len(categories)}")

if __name__ == "__main__":
    main()