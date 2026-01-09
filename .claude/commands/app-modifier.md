Please execute the full following task list

For EACH task in sequence:
1. Read the task requirements carefully
2. Use @app-modifier/app-modify-planner to create implementation plan
3. Review plan at `/modify-plans/task-{ID}/plan.md`
4. Implement the plan exactly
5. Use @app-modifier/error-checker to review and auto-fix any critical issues
6. If reviewer returns "OK", proceed.
7. Document completion in `/modify-plans/task-{ID}/completed.md`
8. Commit with message: "Implement Modify task {ID}: {Title}"
9. Clear context with `/compact` before proceeding to next task

Start with the first task and proceed sequentially.

After ALL tasks are complete, create a task summary at `/modify-plans/task-summary.md` listing:
- Tasks completed
- Any deviations from plans
- Outstanding issues

TASKS: $ARGUMENTS