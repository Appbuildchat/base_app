# Architecture Rules

## MANDATORY File Structure
```
lib/
├── main.dart
├── domain/
│   └── [domain_name]/
│       ├── entities/         # Domain models only
│       ├── functions/        # Business logic only  
│       └── presentation/
│           ├── screens/      # Screen files only
│           └── widgets/      # Reusable widgets only
└── core/
    ├── router/               # GoRouter config
    ├── shell/                # App shell components
    ├── app_error_code.dart   # Error codes enum
    ├── result.dart           # Result<T> wrapper
    └── validator.dart        # Input validators
```

## STRICT Rules

### File Placement
- NEVER create files outside the defined structure
- ALWAYS check if domain exists before creating new one
- NEVER delete or rename existing domains
- ALWAYS use exact folder names (entities, functions, presentation)

### Naming Convention
- Entity files: `{domain_name}_entity.dart`
- Function files: `{feature}_functions.dart`  
- Screen files: `{screen_name}_screen.dart`
- Widget files: `{widget_name}_widget.dart`

### Architecture Patterns
- Clean Architecture: Presentation → Domain → Core (one-way dependency)
- Each domain is self-contained with its own entities, functions, presentation
- Business logic MUST be in functions/ folder
- UI logic MUST be in presentation/ folder
- Shared utilities MUST be in core/ folder

### Implementation Order
1. Run `ls lib/` to check existing structure
2. Create domain folder if needed
3. Create entities first
4. Create functions second  
5. Create presentation last
6. Document in brief file header comment

## FORBIDDEN
- Creating files in root lib/ folder (except main.dart)
- Mixing business logic with UI code
- Cross-domain direct dependencies
- Creating duplicate domains
- Modifying core/ without explicit requirement