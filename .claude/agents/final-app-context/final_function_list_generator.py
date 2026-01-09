#!/usr/bin/env python3
import glob
from pathlib import Path
from collections import defaultdict
import os

def main():
    # Create output directory if it doesn't exist
    output_dir = "output/final-function-list"
    os.makedirs(output_dir, exist_ok=True)

    # Find all function files by domain
    domains = defaultdict(lambda: {"functions": []})

    # Search for all function files in domain directories
    function_pattern = "lib/domain/*/functions/*.dart"
    function_files = glob.glob(function_pattern)

    # Group files by domain
    for file_path in function_files:
        path_parts = file_path.split('/')
        if len(path_parts) >= 4 and path_parts[1] == 'domain':
            domain_name = path_parts[2]  # Extract domain name
            domains[domain_name]["functions"].append(file_path)

    # Generate domain-separated files
    for domain_name, files in domains.items():
        output_file = f"{output_dir}/{domain_name}-function-files.md"

        with open(output_file, 'w') as f:
            f.write(f"# {domain_name.title()} Domain Function Files\n\n")

            if files["functions"]:
                f.write("## Functions\n")
                for func_file in sorted(files["functions"]):
                    f.write(f"- `{func_file}`\n")
            else:
                f.write("## Functions\n")
                f.write("- No function files found\n")

            f.write(f"\n**Total function files: {len(files['functions'])}**\n")

    # Generate summary
    total_functions = sum(len(files["functions"]) for files in domains.values())

    print(f"✅ Generated {len(domains)} domain function file lists")
    print(f"📁 Total domains: {len(domains)}")
    print(f"📄 Total function files: {total_functions}")

    # List generated files
    print("\n📋 Generated files:")
    for domain_name in sorted(domains.keys()):
        function_count = len(domains[domain_name]["functions"])
        print(f"  - {domain_name}-function-files.md ({function_count} functions)")

if __name__ == "__main__":
    main()