# Privacy Notes - Technical Specification

**Version:** 1.0
**Last Updated:** 2026-01-01
**Rails Version:** 8.1.1

## Table of Contents

1. [Feature Overview](#feature-overview)
2. [Core Features](#core-features)
3. [UI/UX Features](#uiux-features)
4. [Technical Implementation](#technical-implementation)
5. [Architecture](#architecture)
6. [Style Guide](#style-guide)
7. [AI Development Instructions](#ai-development-instructions)

---

## Feature Overview

Privacy Notes is a privacy-focused note-taking application inspired by Google Keep, built with Rails 8 and Hotwire. The app emphasizes simplicity, security, and zero external dependencies beyond Ruby/Rails.

### Design Philosophy

- **Vanilla Rails:** No Node.js, no npm, no complex build tools
- **Hotwire-first:** Turbo + Stimulus for reactive UI with minimal JavaScript
- **Privacy-focused:** Secure by default with no third-party tracking
- **Progressive enhancement:** Works without JavaScript, better with it

---

## Core Features

### 1. User Authentication & Preferences

**Authentication:**
- Secure bcrypt password hashing
- Session-based authentication (no JWT)
- Email + password login
- Minimum 8-character password requirement
- Display name for personalization

**User Preferences:**
- Dark mode toggle with persistence
- Theme preference stored in database
- Instant theme switching without page reload
- Server-side rendering respects user preference on initial load

**Technical Details:**
- Model: `User` (email, password_digest, display_name, dark_mode)
- Controller: `SessionsController` for auth, `PreferencesController` for settings
- Theme: Stimulus controller (`theme_controller.js`) with server sync

---

### 2. Note Management

**Note CRUD:**
- Create notes with title and rich content
- Edit notes in modal dialogs
- Delete notes with confirmation
- View note details

**Rich Text Editing:**
- ActionText with Lexxy editor integration
- Custom editor replacing default Trix
- Official Lexxy stylesheets for proper theming
- Dark mode support for editor
- Rich text formatting preserved on note cards

**Note Attributes:**
- Title (optional)
- Rich text content (ActionText)
- Color coding (22 Tailwind colors)
- Pinned status
- Position (for drag-and-drop ordering)
- Tags (many-to-many relationship)
- Timestamps (created_at, updated_at)

**Technical Details:**
- Model: `Note` (belongs_to :user, has_rich_text :content, has_many :tags)
- Controller: `NotesController` with RESTful actions
- Views: Modal-based forms for create/edit
- Rich text rendering: `<%= note.content %>` with `.lexxy-content` class

---

### 3. Note Organization

**Pinning:**
- Pin important notes to the top
- Unpinning moves notes back to regular section
- Turbo page refresh on pin/unpin for proper repositioning
- Uses `turbo_stream.action(:refresh, :morph)` for smooth updates

**Drag-and-Drop Reordering:**
- Reorder notes within pinned and unpinned sections
- Visual drag handle on hover
- Sortable.js integration via importmap
- Position persisted to database
- Separate ordering for pinned vs unpinned notes

**Color Coding:**
- 22 Tailwind color options
- Visual organization and categorization
- Color picker in note form
- Cards display with colored backgrounds

**Tagging:**
- Many-to-many relationship with tags
- Tag model for organization
- Tagging join table
- Display tags on note cards

**Technical Details:**
- Pin/unpin: `NotesController#pin` and `#unpin` actions
- Sortable: Stimulus controller (`sortable_controller.js`)
- Reordering: `NotesController#reorder` action with `Note#insert_at` method
- Position column: Integer field with index, default: 0

---

### 4. Collaboration Features

**Note Sharing:**
- Share notes with other users
- View-only or edit permissions
- Shared notes appear in "Shared with me" section
- Owner identification on shared cards
- Lock indicator for notes being edited

**Edit Locking:**
- Pessimistic locking prevents concurrent edits
- Lock acquired when opening edit modal
- Lock released on save or close
- Visual indicator showing who has the lock
- Cannot edit when locked by another user

**User Connections:**
- Connect with other users
- Manage connections list
- Share notes with connections

**Technical Details:**
- Model: `SharedWith` (note_id, user_id, can_edit)
- Model: `Connection` (user_id, connected_user_id)
- Locking: `Note#lock!`, `#unlock!`, `#locked?`, `#locked_by?`
- Lock fields: `locked_at`, `locked_by_id`

---

### 5. Auto-save

**Functionality:**
- Automatic saving after 1 second of inactivity
- Turbo Streams update without page reload
- Visual feedback during save
- Keeps edit lock active during auto-save
- No manual save button needed

**Technical Details:**
- Stimulus controller: `autosave_controller.js`
- Debounced form submission (1000ms)
- Turbo Stream response maintains lock
- Flash message on successful save

---

### 6. Version History

**Change Tracking:**
- Track all versions of notes
- View version history
- See who made each change
- Timestamp for each version

**Technical Details:**
- Model: `Version` (via PaperTrail or custom implementation)
- Route: `note_versions_path(@note)`
- Link in edit modal to view history

---

## UI/UX Features

### Modal Dialogs

**Implementation:**
- Native HTML5 `<dialog>` element
- No JavaScript library dependencies
- Centered on page with backdrop
- Keyboard support (ESC to close)
- Click backdrop to close
- Turbo Frame for lazy loading content

**Features:**
- Dynamic title based on action (New Note / Editing)
- Close button in header
- Automatic opening when frame loads
- Clean up on close (clear frame content)

**Technical Details:**
- Stimulus controller: `modal_controller.js`
- Targets: `dialog`, `title`
- Data attribute: `data-modal-title` for dynamic titles
- No inline JavaScript in views (DRY principle)

---

### Responsive Design

**Layout:**
- Mobile-first approach
- Responsive grid layout
- 1 column on mobile
- 2 columns on tablet (md)
- 3 columns on desktop (lg)
- 4 columns on large screens (xl)

**Dark Mode:**
- Full dark mode support across all views
- Tailwind dark: variants
- Persists user preference
- Instant switching with smooth transitions
- Lexxy editor dark theme

**Accessibility:**
- Semantic HTML elements
- ARIA labels on interactive elements
- Keyboard navigation support
- Screen reader friendly
- Proper form labels

---

### Visual Feedback

**Interactions:**
- Hover states on cards and buttons
- Active states for drag operations
- Transition animations (shadow, opacity)
- Loading states during operations
- Flash messages for user actions

**Drag-and-Drop:**
- Drag handle visible on hover
- Ghost preview during drag
- Smooth animations (150ms)
- Cursor changes (grab/grabbing)

---

## Technical Implementation

### Frontend Stack

**JavaScript:**
- Hotwire (Turbo + Stimulus)
- Importmap-rails (no Node.js, no npm)
- Stimulus controllers:
  - `autosave_controller.js` - Auto-save functionality
  - `modal_controller.js` - Modal dialog behavior
  - `sortable_controller.js` - Drag-and-drop reordering
  - `theme_controller.js` - Dark mode switching

**CSS:**
- Tailwind CSS v4.1.18 (standalone executable)
- No Node.js required
- Custom Lexxy theme for editor
- Dark mode support via `dark:` variants
- Responsive utilities

**Third-Party JavaScript:**
- Sortable.js v1.15.3 (via CDN, imported via importmap)
- Lexxy editor (custom ActionText editor)

---

### Backend Stack

**Framework:**
- Rails 8.1.1
- Ruby 3.3.6
- SQLite3 for development
- No Redis required

**Rails Components:**
- ActionText for rich text
- Turbo for reactive UI
- Solid Queue for background jobs
- Solid Cache for caching
- Solid Cable for WebSockets
- Propshaft for asset pipeline

**Database:**
- SQLite3 (development)
- Foreign key constraints
- Indexed columns for performance
- Transaction support for data integrity

---

### Database Schema

**Core Models:**

```ruby
User
  - email (string, unique, indexed)
  - password_digest (string)
  - display_name (string)
  - dark_mode (boolean, default: false)
  - timestamps

Note
  - user_id (integer, foreign key, indexed)
  - title (string)
  - color (string)
  - pinned (boolean, default: false, indexed)
  - position (integer, default: 0, indexed)
  - locked_at (datetime)
  - locked_by_id (integer, foreign key)
  - timestamps
  - has_rich_text :content (ActionText)

Tag
  - name (string, unique, indexed)
  - user_id (integer, foreign key)
  - timestamps

Tagging
  - note_id (integer, foreign key, indexed)
  - tag_id (integer, foreign key, indexed)
  - timestamps

SharedWith
  - note_id (integer, foreign key, indexed)
  - user_id (integer, foreign key, indexed)
  - can_edit (boolean, default: false)
  - timestamps

Connection
  - user_id (integer, foreign key, indexed)
  - connected_user_id (integer, foreign key, indexed)
  - timestamps
```

---

### Routing

**RESTful Routes:**

```ruby
# Authentication
get    '/sign_in',  to: 'sessions#new'
post   '/sign_in',  to: 'sessions#create'
delete '/sign_out', to: 'sessions#destroy'
get    '/sign_up',  to: 'users#new'
post   '/sign_up',  to: 'users#create'

# Preferences
patch  '/preferences', to: 'preferences#update'

# Notes
resources :notes do
  member do
    patch :pin
    patch :unpin
    patch :lock
    patch :unlock
    patch :reorder
  end
  resources :versions, only: [:index]
end

# Shared notes
get '/shared', to: 'shared_notes#index', as: :shared_with_me

# Connections
resources :connections, only: [:index, :create, :destroy]

# Tags
resources :tags, only: [:index, :create, :destroy]
```

---

### Key Algorithms

**Note Reordering (`Note#insert_at`):**

```ruby
def insert_at(new_position)
  return if position == new_position

  transaction do
    # Get all notes in the same section (pinned/unpinned)
    notes = user.notes.where(pinned: pinned).order(:position)
    notes = notes.where.not(id: id)
    notes_array = notes.to_a

    # Insert this note at the new position
    notes_array.insert(new_position - 1, self)

    # Update positions for all affected notes
    notes_array.each_with_index do |note, index|
      note.update_column(:position, index + 1) if note.position != (index + 1)
    end
  end
end
```

**Edit Locking:**
- Pessimistic locking with timeout
- Lock acquired on edit, released on save/close
- Visual feedback for locked state
- Cannot edit if locked by another user

---

### Performance Optimizations

**Database:**
- Eager loading with `includes` to prevent N+1 queries
- Indexed foreign keys and frequently queried columns
- Transaction wrapping for data consistency
- Query optimization in controllers

**Frontend:**
- Turbo for instant navigation
- Minimal JavaScript payload
- CSS compiled and cached
- Lazy loading via Turbo Frames

**Caching:**
- Solid Cache for database-backed caching
- Fragment caching where appropriate
- Asset fingerprinting for browser caching

---

### Security Features

**Authentication & Authorization:**
- Bcrypt password hashing (cost: 12)
- Session-based authentication
- CSRF protection enabled
- Strong parameters in controllers
- Permission checks before edit/delete

**Data Protection:**
- SQL injection prevention (ActiveRecord queries)
- XSS protection (Rails escaping by default)
- Mass assignment protection (strong params)
- No sensitive data in logs
- Secure session cookies

**Best Practices:**
- Brakeman security scanner
- Regular dependency updates
- No third-party tracking
- Privacy-focused design

---

## Architecture

### Design Patterns

**MVC with Rails Conventions:**
- Thin controllers, rich models
- Vanilla Rails approach (no services unless justified)
- Concerns for shared behavior
- RESTful resource routing

**Frontend Patterns:**
- Progressive enhancement
- Hotwire for reactivity
- Stimulus for behavior
- Turbo Frames for independence
- Turbo Streams for updates

**Code Organization:**
- Methods ordered by invocation
- Private methods below public
- SRP (Single Responsibility Principle)
- DRY (Don't Repeat Yourself)

---

### Testing Strategy

**Coverage:**
- Controller tests for all actions
- Model tests for business logic
- System tests for critical user flows
- Integration tests matching controller actions

**Approach:**
- Fixtures for stable reference data
- Factories for dynamic scenarios
- Small, focused tests
- Fast execution (prefer fixtures)

**Tools:**
- Minitest (Rails default)
- System tests with Capybara
- Fixtures in `test/fixtures/`
- 112 runs, 286 assertions (all passing)

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
Check the version of a gem when using its functions to ensure we're using the latest features, EG Pagy v43 and Tailwind 4.

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

We use Pagy v43 for pagination.

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
