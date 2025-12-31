# AI Development Instructions

## 📖 Style Guide Reference

**ALWAYS follow the comprehensive style guide at [`docs/STYLE.md`](STYLE.md).**

All code generation, suggestions, and modifications MUST adhere to the patterns, principles, and conventions defined in the style guide. Read and understand it thoroughly before generating any code. Rules in the style guide take precedence over any other instructions.

## 🤖 Core Principles

You are an expert Rails developer following the vanilla Rails philosophy. Generate code that is:
- Simple, readable, and maintainable
- Close to Rails defaults and conventions
- Hotwire-first (Turbo + Stimulus) for frontend
- Fully tested with appropriate coverage
- Secure and performant by default
- **Uses minimal dependencies** - No Node.js, no npm, no complex build tools

### Minimal Dependencies Philosophy

**CRITICAL: This project runs on Ruby/Rails ONLY - No Node.js required.**

- Use importmap-rails for JavaScript (not npm, webpack, or esbuild)
- Use propshaft for asset pipeline (simpler than Sprockets)
- Tailwind CSS uses standalone executable (no Node.js needed)
- Prefer Rails built-in solutions over third-party gems
- Every dependency is a liability - question each one

**Before suggesting any gem or dependency:**
1. Can Rails/Ruby already do this?
2. Can we write a simple solution ourselves?
3. Is the gem actively maintained?
4. Does it require Node.js or additional infrastructure?
5. What's the long-term maintenance burden?

## Code Generation Guidelines

### Before Writing Code
1. **Search for similar patterns** in the codebase and follow them
2. **Check the style guide** for specific guidance
3. **Ask clarifying questions** if requirements are ambiguous
4. **Keep changes minimal** - only modify what's necessary

### What to Generate
- ✅ Clean, focused code solving the specific problem
- ✅ Tests for new functionality
- ✅ i18n keys for all user-facing strings
- ✅ Proper eager loading to prevent N+1 queries
- ✅ Code that passes Rubocop and Brakeman

### What to Avoid
- ❌ Don't add gems without team discussion
- ❌ Don't refactor unrelated code
- ❌ Don't write clever/complex code when simple works
- ❌ Don't create summary text files
- ❌ Don't proceed when tests fail
- ❌ Don't use React/Vue (prefer Hotwire)
- ❌ Don't mix tabs and spaces (use 2-space indentation)

## Rails 8 & Hotwire Defaults

**Frontend:**
- Use Turbo Frames for independent page sections
- Use Turbo Streams for real-time updates
- Use Stimulus for lightweight JavaScript
- Import maps (no webpack/esbuild)
- Only add custom JS when Hotwire isn't sufficient

**Backend:**
- Solid Queue for background jobs
- Solid Cache for caching
- Thin controllers, rich models
- Background jobs: `_later`/`_now` naming pattern

## Testing Strategy

**Prefer fixtures for:**
- Simple, stable reference data (users, roles)
- Fast test execution
- Baseline data reused across tests

**Use factories when:**
- Complex scenarios with specific attributes
- Dynamic or randomized data
- Inline creation improves test readability

## Dependencies & Security

**Before adding gems:**
- Check if Rails/Ruby already provides it
- Verify it's actively maintained
- Discuss with team
- Consider security and performance

**Security checklist:**
- Use strong parameters
- Check authorization
- Never log sensitive data
- Eager load associations in views
- Add indexes for foreign keys and WHERE clauses

## AI Assistant Best Practices

**Your role:**
- Find and match existing patterns first
- Generate code that follows project conventions
- Explain design decisions when asked
- Flag potential issues proactively

**Context management:**
- Break complex tasks into smaller pieces
- Verify changes work before proceeding
- Maintain consistency across the codebase
- Ask for output/results when needed

**Responsibility:**
You are accountable for all code you generate. Review, understand, and ensure it meets quality standards before suggesting it.

## Success Checklist

Before considering code complete:
- [ ] Passes Rubocop without warnings
- [ ] All tests pass (including new ones)
- [ ] Matches existing project patterns
- [ ] Changes are minimal and focused
- [ ] Security checks pass (Brakeman)
- [ ] You can explain every design decision

---

**When in doubt:** Check [`docs/STYLE.md`](STYLE.md) for detailed guidance.
