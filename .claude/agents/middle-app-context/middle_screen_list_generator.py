#!/usr/bin/env python3
"""
Domain-Separated Flutter Presentation File Scanner
Generates clean file lists per domain for targeted analysis
"""

import glob
from pathlib import Path
from collections import defaultdict
import os

def main():
    """Generate domain-separated file lists"""
    # Create output directory if it doesn't exist
    output_dir = "output/middle-list"
    os.makedirs(output_dir, exist_ok=True)

    # Find all presentation files by domain
    domains = defaultdict(lambda: {"screens": [], "widgets": []})

    # Scan screens
    screen_files = glob.glob("lib/domain/*/presentation/screens/**/*.dart", recursive=True)
    for screen in screen_files:
        domain = Path(screen).parts[2]  # lib/domain/[domain]/presentation/...
        domains[domain]["screens"].append(screen)

    # Scan widgets
    widget_files = glob.glob("lib/domain/*/presentation/widgets/**/*.dart", recursive=True)
    for widget in widget_files:
        domain = Path(widget).parts[2]  # lib/domain/[domain]/presentation/...
        domains[domain]["widgets"].append(widget)

    # Generate domain-separated files
    total_screens = 0
    total_widgets = 0

    for domain_name, files in domains.items():
        screens = sorted(files["screens"])
        widgets = sorted(files["widgets"])

        # Count totals
        total_screens += len(screens)
        total_widgets += len(widgets)

        # Generate markdown content for this domain
        content = f"# {domain_name.title()} Domain Presentation Files\n\n"

        if screens:
            content += "## Screens\n"
            for screen in screens:
                content += f"- `{screen}`\n"
            content += "\n"

        if widgets:
            content += "## Widgets\n"
            for widget in widgets:
                content += f"- `{widget}`\n"
            content += "\n"

        # Save domain-specific file
        output_file = f"{output_dir}/{domain_name}-presentation-files.md"
        with open(output_file, "w", encoding='utf-8') as f:
            f.write(content)

        print(f"✅ {domain_name.title()} domain: {len(screens)} screens, {len(widgets)} widgets → {output_file}")

    # Generate summary
    print(f"\n📊 Total: {total_screens} screens, {total_widgets} widgets across {len(domains)} domains")
    print(f"🎯 Domain files created in {output_dir}/ directory")

if __name__ == "__main__":
    main()