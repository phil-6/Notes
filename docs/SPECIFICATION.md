# Privacy Notes - Product Specification

**A privacy-focused note-taking application inspired by Google Keep**

This document describes what to build and the architectural principles to follow. It serves as the single source of truth for recreating this application.

---

## Table of Contents

1. [Vision & Principles](#vision--principles)
2. [User Features](#user-features)
3. [Technical Framework](#technical-framework)
4. [Style Guide](#style-guide)
5. [AI Development Instructions](#ai-development-instructions)

---

## Vision & Principles

### Product Vision

Create a simple, fast, privacy-focused note-taking application that feels like Google Keep but respects user privacy. Notes should be quick to create, easy to organize, and beautiful to use in both light and dark modes.

### Core Principles

**Simplicity First**
- Zero learning curve - users should understand everything immediately
- No overwhelming features or complex navigation
- Quick note creation without friction

**Privacy Focused**
- No third-party tracking or analytics
- All data stays on your server
- No external dependencies for core functionality

**Beautiful & Fast**
- Instant interactions with no loading states
- Smooth animations and transitions
- Responsive design from mobile to desktop
- Full dark mode support

**Progressive Enhancement**
- Works without JavaScript, better with it
- Accessible to all users
- Keyboard navigation throughout

---

## User Features

### 1. Account Management

**Sign Up & Sign In**
- Users create accounts with email and password
- Password must be at least 8 characters
- Each user has a display name shown throughout the app
- Session-based authentication (no tokens)

**User Preferences**
- Dark mode toggle in header
- Preference persists across sessions
- Theme applies immediately without page reload
- All UI elements respect theme choice

---

### 2. Creating & Editing Notes

**Quick Note Creation**
- Click "New Note" to open a modal
- Add optional title
- Rich text editor for content
- Choose from 22 color options
- Add tags for organization
- Auto-saves after 1 second of inactivity

**Rich Text Editing**
- Use Lexxy editor for rich text
- Support bold, italic, lists, links
- Dark mode support in editor
- Formatting preserved on note cards

**Editing Notes**
- Click any note card to edit
- Opens same modal as creation
- Auto-save keeps changes without manual saving
- Edit lock prevents concurrent editing by multiple users

---

### 3. Organizing Notes

**Visual Organization**
- Notes displayed in responsive grid
  - 1 column on mobile
  - 2 columns on tablet
  - 3 columns on laptop
  - 4 columns on desktop
- Each note shows as a colored card
- Hover reveals actions (pin, delete, drag handle)

**Pinning**
- Pin important notes to keep them at top
- Pinned section appears above regular notes
- Click pin icon to toggle
- Notes move between sections smoothly

**Drag-and-Drop Reordering**
- Drag notes to reorder within sections
- Visual drag handle appears on hover
- Separate ordering for pinned and unpinned notes
- Position persists across sessions

**Color Coding**
- 22 Tailwind colors available
- Set color when creating or editing
- Cards display with colored background
- Use colors to categorize notes visually

**Tagging**
- Create tags to organize notes
- Add multiple tags to each note
- Tags display on note cards
- Filter notes by tag (future enhancement)

---

### 4. Collaboration

**Sharing Notes**
- Share individual notes with other users
- Set view-only or edit permissions
- Shared notes appear in "Shared with me" section
- Owner's name visible on shared cards

**Edit Locking**
- When someone opens a note, it locks
- Other users see who has the lock
- Cannot edit while locked by someone else
- Lock releases when editor closes or saves

**Connections**
- Connect with other users
- Manage your connections list
- Makes sharing easier

---

### 5. Additional Features

**Version History**
- Every change to a note creates a version
- View history of changes
- See who made each change and when
- Link to history in edit modal

**Delete Notes**
- Delete button on each card (on hover)
- Confirmation dialog before deleting
- Permanent deletion (no trash/recovery)

**Note Cards Display**
- Title shown prominently (if present)
- Rich text content preview with formatting
- Tags displayed as badges
- Color-coded background
- Actions appear on hover

---

## Technical Framework

### Technology Stack

**Core Framework**
- Rails (latest stable version)
- Ruby (latest stable version)
- SQLite3 for development database
- No Node.js required anywhere

**Frontend Approach**
- Vanilla Rails with Hotwire (Turbo + Stimulus)
- As little JavaScript as possible
- Use Turbo for all navigation and updates
- Stimulus only for interactive behaviors
- Importmap for JavaScript (no npm, webpack, or build tools)

**Styling**
- Tailwind CSS (latest version, standalone executable)
- Custom Lexxy theme for editor
- Full dark mode throughout
- Mobile-first responsive design

**Rich Text**
- ActionText for rich text storage
- Lexxy editor instead of default Trix
- Official Lexxy stylesheets
- Dark mode support

**Authentication**
- Rails default authentication approach
- Bcrypt for password hashing
- Session-based (no JWT)
- Strong parameters for security

### Architectural Decisions

**No External Dependencies**
- Prefer Rails built-in solutions
- Solid Queue instead of Sidekiq
- Solid Cache instead of Redis
- Solid Cable for WebSockets
- Every dependency must justify its existence

**JavaScript Philosophy**
- Use Turbo Frames for modal dialogs
- Use Turbo Streams for live updates
- Stimulus controllers should be small and focused
- Only one external JS library: Sortable.js (for drag-and-drop)
- No inline JavaScript in views

**Database Design**
- RESTful resource routing
- Proper foreign key constraints
- Index all foreign keys and frequently queried columns
- Eager load associations to prevent N+1 queries

**Code Organization**
- Thin controllers, rich models
- No services unless clearly beneficial
- Concerns for shared behavior
- Keep methods short and focused
- Follow Rails conventions strictly

### Key Implementation Patterns

**Modal Dialogs**
- Use native HTML5 `<dialog>` element
- Turbo Frames load content lazily
- Center modals on screen
- ESC key to close
- Click backdrop to close

**Pin/Unpin Behavior**
- Use Turbo page refresh (morph) to reposition cards
- Updates entire page smoothly
- Maintains scroll position

**Drag-and-Drop**
- Use Sortable.js library (via importmap)
- Handle icon shows on hover
- Updates position in database
- Separate ordering for pinned/unpinned sections

**Auto-save**
- Debounce form submission (1 second)
- Turbo Streams for updates
- Maintains edit lock during auto-save

**Dark Mode**
- Server renders initial theme state
- Client-side toggle updates immediately
- Saves preference to server in background
- Checkbox wrapped in label for click reliability

### Security Requirements

- Strong parameters in all controllers
- CSRF protection enabled
- XSS protection (Rails default escaping)
- SQL injection prevention (use ActiveRecord)
- Never log sensitive data
- Check permissions before all modifications
- Session-based auth only

### Performance Requirements

- Eager load associations to prevent N+1 queries
- Index foreign keys and WHERE/ORDER BY columns
- Use transactions for multi-record updates
- Fragment caching where beneficial
- Fast test suite using fixtures

### Testing Requirements

- Full controller test coverage
- Model tests for business logic
- System tests for critical user flows
- Use fixtures for test data (faster than factories)
- All tests must pass before deployment

---

## Database Models

**User**
- Email (unique, indexed)
- Password (hashed with bcrypt)
- Display name
- Dark mode preference
- Standard timestamps

**Note**
- Belongs to user
- Title (optional)
- Rich text content (ActionText)
- Color (string)
- Pinned (boolean, indexed)
- Position (integer, indexed)
- Lock information (timestamp, locked_by user)
- Standard timestamps

**Tag**
- Name (unique per user, indexed)
- Belongs to user
- Many-to-many with notes through Tagging

**Tagging**
- Join table for notes and tags
- Both foreign keys indexed

**SharedWith**
- Note can be shared with user
- Permission level (can_edit boolean)
- Both foreign keys indexed

**Connection**
- User connects with another user
- Both foreign keys indexed

**Version** (for change tracking)
- Store who made changes
- Store when changes were made
- Link to note and user

---

# Style Guide

This is the style guide for Privacy Notes. Some of this is taken from the Fizzy (by 37 Signals) style guide.

We should discuss and evolve this document as we go.

From Fizzy's style guide:

> We aim to write code that is a pleasure to read, and we have a lot of opinions about how to do it well. Writing great code is an essential part of our programming culture, and we deliberately set a high bar for every code change anyone contributes. We care about how code reads, how code looks, and how code makes you feel when you read it.

> We love discussing code. If you have questions about how to write something, or if you detect some smell you are not quite sure how to solve, please ask away to other programmers. A Pull Request is a great way to do this.

> When writing new code, unless you are very familiar with our approach, try to find similar code elsewhere to look for inspiration.

We want the code to be clean, maintainable, modular and reusable. We should use concerns and other sensible extractions where appropriate. Key principles are:

- Keep it Simple,
- Keep it as close to the rails defaults as possible,
- SRP and
- DRY

Our code should be predictable and self-explanatory. Naming things is hard, but we should take the time to name things well.

We should have a clear separation of concerns. Aim to avoid methods that have extra side effects. Classes should have a single, well-defined responsibility.

Efforts should be made to avoid "Clever" code. Simple, understandable code is always better than the complex "clever" solution. If you find yourself writing clever code, consider whether there is a simpler path. Can we break down the problem into smaller parts, or can we extract some of the complexity into a well named method or class?

We should often be WET before we are DRY. (Write Everything Twice before we Don't Repeat Ourselves). Two usages of something is often not enough to justify an abstraction, three usually is. Another case for extraction is to break up large files, classes or methods into smaller, more manageable pieces. Keeping SRP in mind.

## Method and Class Size

Keep methods short and focused. If a method is getting long (more than ~12 lines), consider breaking it into smaller, well-named private methods. Each method should do one thing well.

Similarly, keep classes focused on a single responsibility. If a class is growing beyond ~150 lines, consider whether it's doing too much and should be split.

These aren't hard rules, but they're good indicators that you should pause and consider refactoring.

## Comments and Documentation

Code should be self-documenting through clear naming and structure, so comments are not generally needed. Comments should explain **why**, not **what** the code does.

**Good comments:**
- Explain business logic or domain-specific rules
- Document non-obvious decisions or trade-offs
- Clarify complex algorithms when simplification isn't possible
- Add context that isn't clear from the code itself

**Avoid comments that:**
- Restate what the code does (the code should be clear enough)
- Apologise for bad code (refactor instead)
- Are outdated or contradictory to the code

When you feel you need a comment to explain what code does, first try to refactor the code to be more self-explanatory through better naming or extraction.

## As Close to the Rails Defaults as Possible

We should aim to keep our code as close to the Rails defaults as possible. This helps with maintainability, and makes it easier for new developers to get up to speed. It also makes upgrading Rails versions easier. Follow Rails conventions and idioms. Prioritize "Convention over Configuration".

### Minimal Dependencies

**Keep dependencies to an absolute minimum.** Every dependency is a liability that can break, require updates, or introduce security vulnerabilities.

**No Node.js Required:**
- This project runs entirely on Ruby/Rails
- We use importmap-rails for JavaScript (no npm, webpack, or node_modules)
- We use propshaft for asset pipeline (simpler than Sprockets)
- Tailwind CSS uses the standalone executable via tailwindcss-rails gem (no Node.js needed)
- Stimulus controllers are loaded via importmap

**Before Adding Any Dependency:**
1. Can Rails/Ruby do this already?
2. Can we write a simple solution ourselves?
3. Is the gem actively maintained?
4. What's the maintenance burden?
5. Does it require additional infrastructure (Node.js, Redis, etc.)?

**Prefer Rails Defaults:**
- Solid Queue over Sidekiq (no Redis required)
- Solid Cache over Redis/Memcached
- Solid Cable over Action Cable with Redis
- SQLite3 for development (simple, no server required)
- ActionText over third-party WYSIWYG editors
- Hotwire over React/Vue

### Gems and Libraries

We should avoid using additional gems where possible. We should discuss as a team before implementing new gems and clearly identify what pain they are solving and what benefits they bring.

Always use the latest stable version of gems and check their documentation for current best practices.

### Turbo and JavaScript

We should use turbo wherever possible. Avoid adding additional JavaScript where turbo can handle the job. We're using StimulusJS as the JS controller, which keeps things close to vanilla JS. Stimulus controllers should be small, lightweight, reusable and focused on a single task.

When we lazy load with a turbo frame, we should ensure that the response view renders a complete page (with layout) so if the route is accessed directly without Turbo, the user sees a proper page rather than orphaned content.

## Tailwind

We use Tailwind CSS for styling.

We should keep tailwind DRYish. If there is a particular combination of classes we use in multiple places, with the same intent, we should extract it to a component or an @apply directive in tailwind/application.css or one of the other css files.

## Testing

Controllers and models should have full test coverage.

Integration tests should usually match up with controller actions.

Key User flows should have system tests for the happy-path.

Tests should be small and focused. Split large tests into multiple tests files with singular focus.

Prefer using fixtures for test data. Avoid using `create` in tests unless absolutely necessary. Performance in tests is important.

## Tooling

We use Rubocop to enforce consistent code style. Run `bin/rubocop` before committing to check for violations. The configuration is in `.rubocop.yml`.

We use Tailwind for CSS. We try and keep styles DRY where appropriate.

We use brakeman for static analysis and security checks.

We use Pagy for pagination (latest stable version).

## i18n

All user facing strings should be i18n'd. Use sensible keys that match the structure of the application. For example, user profile related strings should go under `users.profile.*`.

## Routing

Typically, our routes should be RESTful and resourceful. Generally, we should avoid custom routes.

When we do create custom routes, they should be descriptive of the action they perform.

## Database & Performance

- **Eager loading**: Use `includes`, `preload`, or `eager_load` to prevent N+1 queries. When you add an association that will be accessed in a loop, think about whether it needs eager loading.
- **Indexes**: Consider adding indexes when adding foreign keys or columns that will be used in WHERE or ORDER BY clauses.
- **No queries from views**: Keep database queries in controllers and models. Views should only render data that's already been loaded—this keeps the view layer simple and makes N+1 issues easier to spot.

## Methods ordering

We order methods in classes in the following order:

1. `class` methods
2. `public` methods with `initialize` at the top.
3. `private` methods

## Invocation order

We order methods vertically based on their invocation order. This helps us to understand the flow of the code.

```ruby
class SomeClass
    def some_method
      method_1
      method_2
    end

    private
    def method_1
      method_1_1
      method_1_2
    end

    def method_1_1
      # ...
    end

    def method_1_2
      # ...
    end

    def method_2
      method_2_1
      method_2_2
    end

    def method_2_1
      # ...
    end

    def method_2_2
      # ...
    end
end
```

## To bang or not to bang

Should I call a method `do_something` or `do_something!`?

As a general rule, we only use `!` for methods that have a correspondent counterpart without `!`. In particular, we don't use `!` to flag destructive actions. There are plenty of destructive methods in Ruby and Rails that do not end with `!`.

## Visibility modifiers

We don't add a newline under visibility modifiers, and we don't indent the content under them.

```ruby
class SomeClass
  def some_method
    # ...
  end

  private
  def some_private_method_1
    # ...
  end

  def some_private_method_2
    # ...
  end
end
```

## Controller and model interactions

In general, we favour a [vanilla Rails](https://dev.37signals.com/vanilla-rails-is-plenty/) approach with thin controllers directly invoking a rich domain model. We avoid using services or other artifacts to connect the two.

Invoking plain Active Record operations is totally fine:

```ruby
class Cards::CommentsController < ApplicationController
  def create
    @comment = @card.comments.create!(comment_params)
  end
end
```

For more complex behaviour, we prefer clear, intention-revealing model APIs that controllers call directly:

```ruby
class Cards::GoldnessesController < ApplicationController
  def create
    @card.gild
  end
end
```

When justified, it is fine to use services or form objects, but don't treat those as special artifacts:

```ruby
Signup.new(email_address: email_address).create_identity
```

Naming of class types is descriptive in Rails. A service is a class that performs some sort service. It performs an action.
Don't overthink it.

## Run async operations in jobs

As a general rule, we write shallow job classes that delegate the logic itself to domain models or services. Job classes should not contain any logic themselves.

* We typically use the suffix `_later` to flag methods that enqueue a job.
* A common scenario is having a model class that enqueues a job that, when executed, invokes some method in that same class. In this case, we use the suffix `_now` for the regular synchronous method.

```ruby
module Event::Relaying
  extend ActiveSupport::Concern

  included do
    after_create_commit :relay_later
  end

  def relay_later
    Event::RelayJob.perform_later(self)
  end

  def relay_now
    # ...
  end
end

class Event::RelayJob < ApplicationJob
  def perform(event)
    event.relay_now
  end
end
```

## Accessibility

We should be mindful of accessibility as we build. A few things to keep in mind:

- Prefer semantic HTML elements (`<nav>`, `<main>`, `<article>`, `<button>`, etc.) over generic divs and spans
- Add ARIA attributes where semantic HTML alone isn't enough to convey meaning
- Ensure interactive elements can be used with a keyboard
- Provide text alternatives for images and icons where appropriate

## Security Considerations

Security should be built into our code from the start, Rails comes with many built-in protections, but we should be mindful of common pitfalls:

- **Strong parameters**: Always use strong parameters in controllers to whitelist attributes
- **Authorization**: Check permissions before performing actions (use policies/pundit where appropriate)
- **Authentication**: Ensure users are authenticated for protected actions
- **SQL injection**: Use ActiveRecord's query interface; parameterize raw SQL queries
- **XSS protection**: Rails escapes output by default; only use `raw` or `html_safe` when necessary and with sanitised input
- **Mass assignment**: Use strong parameters; be careful with `permit!`
- **Sensitive data**: Never log passwords, tokens, or other sensitive information
- **CSRF protection**: Don't disable CSRF protection without good reason

---

# AI Development Instructions

## 📖 Style Guide Reference

**ALWAYS follow the comprehensive style guide above.**

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

## Rails & Hotwire Defaults

**Frontend:**
- Use Turbo Frames for independent page sections
- Use Turbo Streams for real-time updates
- Use Stimulus for lightweight JavaScript
- Import maps (no webpack/esbuild)
- Only add custom JS when Hotwire isn't sufficient

**Backend:**
- Use latest stable Rails version
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

**When in doubt:** Refer to the style guide above for detailed guidance.
