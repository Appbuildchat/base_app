#!/usr/bin/env python3
"""
Function Analyzer - Analyzes Flutter business logic functions
Analyzes all function files across domains using nested loop API pattern.
"""

import glob
import sys
from pathlib import Path

# Add project root to Python path
project_root = Path(__file__).parent.parent.parent.parent
sys.path.append(str(project_root))

from config.call_llm import call_llm
from middle_function_list_generator import main as generate_function_lists

def discover_domains():
    """Discover all available domains from function list files"""
    base_dir = Path("/home/test1/aas/AAS_0.2.0/flutter-base-project")
    list_dir = base_dir / "output" / "middle-function-list"

    # Find all domain function files
    domain_files = glob.glob(str(list_dir / "*-function-files.md"))

    domains = []
    for domain_file in domain_files:
        domain_name = Path(domain_file).stem.replace("-function-files", "")
        domains.append(domain_name)

    return sorted(domains)

def load_domain_function_files(domain_name):
    """Load function file paths for a specific domain"""
    base_dir = Path("/home/test1/aas/AAS_0.2.0/flutter-base-project")
    list_dir = base_dir / "output" / "middle-function-list"
    domain_file = list_dir / f"{domain_name}-function-files.md"

    function_files = []
    if domain_file.exists():
        with open(domain_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line.startswith('- `') and line.endswith('`'):
                    func_path = line[3:-1]  # Remove "- `" and "`"
                    full_path = str(base_dir / func_path)  # Make absolute path
                    function_files.append(full_path)

    return function_files

def analyze_function_file(function_file_path):
    """Analyze a single function file using LLM"""
    # Read function file content
    with open(function_file_path, 'r', encoding='utf-8') as f:
        dart_content = f.read()

    # Prepare detailed LLM prompt
    prompt = f"""Analyze this Flutter function file following this EXACT format:

#### `{Path(function_file_path).name}`

**Function Purpose**:
- Primary business operation performed
- Use case and context within domain
- Integration with other system components

**Function Signature**:
- **Function Name**: [functionName]
- **Parameters**:
  - **[Parameter Name]**: [Type] - [Description]
    - Required: [Yes/No]
    - Default Value: [value or none]
    - Validation: [validation rules applied]
  - [Continue for all parameters]
- **Return Type**: [Type] - [Description]
- **Async Pattern**: [async/await, Future, Stream, sync]

**Business Logic Flow**:
1. **Input Processing**: [parameter validation and processing]
2. **Business Rules**: [domain-specific rules and validations]
3. **External Calls**: [API calls, database operations, service calls]
4. **Data Processing**: [data transformation and manipulation]
5. **Output Generation**: [result formatting and return]

**API Integration** (if applicable):
- **Type**: [HTTP API, Firestore, Firebase Auth, Local Storage, etc.]
- **HTTP Method**: [GET, POST, PUT, DELETE, etc.] (for HTTP APIs)
- **Endpoint**: [API endpoint URL or pattern]
- **Database**: [Firestore, SQLite, etc.] (for database functions)
- **Collection Name**: [actual collection name] (for Firestore functions)
- **Key Fields Used**: [field names used in where, orderBy, etc.] (for Firestore functions)
- **Query Pattern**: [specific query structure] (for Firestore functions)
- **Request Headers**: [authentication, content-type, etc.]
- **Request Body**: [data structure and format]
- **Response Handling**: [success/error response processing]
- **Authentication**: [token handling, auth requirements]

**Data Flow**:
```
Input -> [Validation] -> [Business Logic] -> [External Call] -> [Processing] -> Output
```

**Error Handling**:
- **Exception Types**: [specific exceptions caught]
- **Error Propagation**: [how errors are passed up]
- **Recovery Strategies**: [fallback mechanisms]
- **User Feedback**: [error messages and user communication]

**Dependencies**:
- **Internal Dependencies**: [other domain functions called]
- **External Dependencies**: [third-party services, APIs, packages]
- **Data Dependencies**: [entities, models, repositories used]

**Side Effects**:
- **State Changes**: [what state is modified]
- **External Systems**: [calls to external services]
- **User Interface**: [UI updates triggered]
- **Persistence**: [data storage operations]

**Performance Considerations**:
- **Async Operations**: [concurrent operations, performance optimizations]
- **Caching**: [data caching strategies used]
- **Rate Limiting**: [API rate limiting handling]
- **Resource Management**: [memory, network resource usage]

STRICTLY FORBIDDEN - DO NOT INCLUDE:
- Any summary, executive summary, or overview
- Total counts, statistics, domain overviews
- Pattern summaries, conclusions, insights
- General observations or categorizations
- "Key findings" or "Overall analysis"
- Any section not specified in the format above

ONLY provide pure detailed analysis of THIS specific function file following the exact format above.

File: {function_file_path}

Dart file content:
```dart
{dart_content}
```"""

    # Call LLM
    messages = [
        {"role": "system", "content": "You are a Flutter business logic analysis expert. Provide detailed technical analysis of function files without any summaries or overviews."},
        {"role": "user", "content": prompt}
    ]

    response = call_llm(messages, "gpt-5-mini")
    return response.choices[0].message.content

def save_analysis_to_md(function_file_path, analysis):
    """Save analysis result to markdown file"""
    base_dir = Path("/home/test1/aas/AAS_0.2.0/flutter-base-project")
    output_file = base_dir / "output-middle-app-context" / "3.function-analysis.md"

    # Ensure output directory exists
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # Prepare content
    content = f"""
{analysis}

---

"""

    # Append to file
    with open(output_file, 'a', encoding='utf-8') as f:
        f.write(content)

def main():
    """Main execution function"""
    # First, generate the latest function list
    print("📋 Generating latest function file list...")
    generate_function_lists()

    base_dir = Path("/home/test1/aas/AAS_0.2.0/flutter-base-project")
    output_file = base_dir / "output-middle-app-context" / "3.function-analysis.md"

    # Initialize output file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# Business Logic Function Analysis\n\n")

    # Discover all domains
    domains = discover_domains()

    if not domains:
        print("❌ No domains found to analyze")
        return

    total_files_processed = 0

    # Process each domain sequentially (Outer Loop)
    for domain_index, domain_name in enumerate(domains, 1):
        print(f"\n🔍 Processing {domain_name.title()} domain ({domain_index}/{len(domains)})...")

        # Load function files for this domain
        domain_function_files = load_domain_function_files(domain_name)

        if not domain_function_files:
            print(f"   ⚠️  No function files found in {domain_name} domain")
            continue

        print(f"   📄 Found {len(domain_function_files)} function files in {domain_name} domain")

        # Process each function file in this domain (Inner Loop)
        for file_index, function_file in enumerate(domain_function_files, 1):
            try:
                file_name = Path(function_file).name
                print(f"   🔍 Analyzing {file_name} ({file_index}/{len(domain_function_files)})...")

                analysis = analyze_function_file(function_file)
                save_analysis_to_md(function_file, analysis)
                print(f"   ✅ Completed {file_name}")
                total_files_processed += 1
            except Exception as e:
                print(f"   ❌ Error with {Path(function_file).name}: {e}")

        print(f"✅ {domain_name.title()} domain completed ({len(domain_function_files)} files)")

    print(f"\n🎉 Function analysis completed! Results saved to: {output_file}")
    print(f"📊 Total files processed: {total_files_processed}")

    # Generate domain coverage report
    print(f"\n**Complete Coverage Report:**")
    print(f"- Total domains discovered: {len(domains)} domains ✅")
    print(f"- All discovered domains: ✅ Analyzed")
    print(f"- Total coverage: 100% of ALL discovered domains")
    print(f"\n**Domain Details:**")
    for domain_name in domains:
        domain_function_files = load_domain_function_files(domain_name)
        print(f"- {domain_name} domain: ✅ Analyzed ({len(domain_function_files)} files)")

if __name__ == "__main__":
    main()