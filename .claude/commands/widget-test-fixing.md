# Widget Test Fixing

Runs and fixes generated Flutter widget tests for domain-specific features until all tests pass.

For the specified domain test files:
1. Parse domain name from test file argument (e.g., "admin-test-files.md" → "admin")
2. Identify generated test files in `test/domain/{domain}/`
3. Run initial `flutter test test/domain/{domain}/` to check current status
4. Use @widget-test/widget-test-reviewer to review and auto-fix any critical issues
5. If reviewer returns "OK", proceed to completion
6. Document final test results in `/plans/widget-test-{domain}/test-results.md`

## Implementation Standards
- **Completeness**: ALL generated tests must pass - no exceptions
- **Real Integration**: Tests must work with actual lib code
- **Flutter Standards**: Use proper testWidgets, finders, and matchers

## Success Criteria
- 100% test pass rate for the domain
- All tests execute without compilation errors
- Tests complete in reasonable time

DOMAIN: $ARGUMENTS