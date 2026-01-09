#!/usr/bin/env python3
"""
Widget Test File Picker
Scans lib/domain/ structure and generates test file lists for each domain.
Creates output files in output-widget-test-list/ directory.
"""

from pathlib import Path
from datetime import datetime


def scan_domain_files(base_dir):
    """Scan lib/domain/ directory and collect all presentation and function files by domain."""
    domain_dir = base_dir / "lib" / "domain"
    domain_files = {}

    if not domain_dir.exists():
        print(f"❌ Error: {domain_dir} does not exist")
        return domain_files

    print(f"🔍 Scanning {domain_dir} for domain files...")

    # Find all domains
    for domain_path in domain_dir.iterdir():
        if domain_path.is_dir():
            domain_name = domain_path.name
            domain_files[domain_name] = {
                'presentation': [],
                'functions': []
            }

            # Scan presentation files
            presentation_dir = domain_path / "presentation"
            if presentation_dir.exists():
                for dart_file in presentation_dir.rglob("*.dart"):
                    relative_path = dart_file.relative_to(base_dir)
                    domain_files[domain_name]['presentation'].append(str(relative_path))

            # Scan function files
            functions_dir = domain_path / "functions"
            if functions_dir.exists():
                for dart_file in functions_dir.rglob("*.dart"):
                    relative_path = dart_file.relative_to(base_dir)
                    domain_files[domain_name]['functions'].append(str(relative_path))

    return domain_files


def generate_test_file_paths(source_files):
    """Generate corresponding test file paths for source files."""
    test_files = []

    for source_file in source_files:
        # Convert lib/domain/xxx/... to test/domain/xxx/...
        test_file = source_file.replace("lib/", "test/")
        # Add _test suffix before .dart extension
        test_file = test_file.replace(".dart", "_test.dart")
        test_files.append(test_file)

    return test_files


def create_domain_test_file_list(base_dir, domain_name, domain_data):
    """Create test file list for a specific domain."""
    output_dir = base_dir / "output-widget-test-list"
    output_file = output_dir / f"{domain_name}-test-files.md"

    content = []
    content.append(f"# {domain_name.title()} Domain Test Files")
    content.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    content.append("")

    # Presentation files section
    if domain_data['presentation']:
        content.append("## Presentation Files (Widget Tests)")
        content.append("")
        content.append("### Source Files:")
        for file in sorted(domain_data['presentation']):
            content.append(f"- {file}")

        content.append("")
        content.append("### Test Files to Create:")
        test_files = generate_test_file_paths(domain_data['presentation'])
        for file in sorted(test_files):
            content.append(f"- {file}")
        content.append("")
    else:
        content.append("## Presentation Files (Widget Tests)")
        content.append("*No presentation files found*")
        content.append("")

    # Functions files section
    if domain_data['functions']:
        content.append("## Function Files (Unit Tests)")
        content.append("")
        content.append("### Source Files:")
        for file in sorted(domain_data['functions']):
            content.append(f"- {file}")

        content.append("")
        content.append("### Test Files to Create:")
        test_files = generate_test_file_paths(domain_data['functions'])
        for file in sorted(test_files):
            content.append(f"- {file}")
        content.append("")
    else:
        content.append("## Function Files (Unit Tests)")
        content.append("*No function files found*")
        content.append("")


    # Write file
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(content))
        print(f"📝 Created: {output_file}")
        return True
    except Exception as e:
        print(f"❌ Error writing {output_file}: {e}")
        return False


def main():
    # Define paths
    base_dir = Path("/home/test1/aas/AAS_0.2.0/flutter-base-project")
    output_dir = base_dir / "output-widget-test-list"

    # Create output directory
    output_dir.mkdir(exist_ok=True)
    print(f"📁 Output directory: {output_dir}")

    # Scan domain files
    domain_files = scan_domain_files(base_dir)

    if not domain_files:
        print("❌ No domain files found")
        return False

    print(f"📊 Found {len(domain_files)} domains")

    # Generate test file lists for each domain
    success_count = 0
    for domain_name, domain_data in domain_files.items():
        total_files = len(domain_data['presentation']) + len(domain_data['functions'])
        print(f"🔧 Processing {domain_name}: {total_files} files")

        if create_domain_test_file_list(base_dir, domain_name, domain_data):
            success_count += 1

    print(f"✅ Successfully created {success_count}/{len(domain_files)} domain test file lists")
    print(f"📂 Output location: {output_dir}")

    return success_count == len(domain_files)


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)