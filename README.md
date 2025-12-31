# Privacy Notes

A privacy-focused note-taking application built with Rails 8, inspired by Google Keep. Features include rich text editing, color-coded notes, pinning, tagging, sharing, and dark mode support.

## Features

### 🎨 Core Features
- **Rich Text Editing** - ActionText with Trix editor for formatted content
- **Color Coding** - 22 Tailwind colors to organize and categorize notes
- **Pinning** - Pin important notes to the top
- **Auto-save** - Notes save automatically after 1 second of inactivity
- **Tags & Categories** - Organize notes with tags
- **Dark Mode** - User preference for dark mode with full UI support
- **Note Sharing** - Share notes with other users (coming soon)
- **Change Tracking** - Version history for notes (coming soon)

### 🔐 Security & Privacy
- Secure authentication with bcrypt
- Session-based auth (no JWT tokens)
- Strong parameter filtering
- CSRF protection
- Privacy-focused design

### 📱 Technology Stack
- **Rails 8.1.1** - Latest Rails with modern defaults
- **Hotwire** - Turbo + Stimulus for reactive UI without heavy JavaScript
- **Tailwind CSS 4** - Modern, responsive styling
- **SQLite3** - Lightweight database for development
- **ActionText** - Rich text editing
- **Solid Queue** - Background job processing
- **Solid Cache** - Database-backed caching
- **Solid Cable** - WebSocket connections

## Getting Started

### Prerequisites
- Ruby 3.3.6
- SQLite3

**No Node.js required!** This application uses importmap-rails and the standalone Tailwind CSS executable, so you can run it with just Ruby.

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Notes
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
bin/rails db:create db:migrate
```

4. Start the development server:
```bash
bin/dev
```

5. Visit [http://localhost:3000](http://localhost:3000)

### Creating Your First Account

1. Navigate to the sign-up page
2. Enter your email, display name, and password (minimum 8 characters)
3. Start creating notes!

## Development

### Running Tests

```bash
bin/rails test
bin/rails test:system
```

### Code Quality

Run Rubocop to check code style:
```bash
bin/rubocop
```

Run Brakeman for security analysis:
```bash
bin/brakeman
```

### Style Guide

All code should follow the comprehensive style guide in [`docs/STYLE.md`](docs/STYLE.md). Key principles:
- Keep it simple
- Stay close to Rails defaults
- Single Responsibility Principle
- Don't Repeat Yourself (but be WET before DRY)
- Self-documenting code over comments

### AI Development

When using AI to contribute to this project, see [`docs/AI_INSTRUCTIONS.md`](docs/AI_INSTRUCTIONS.md) for detailed guidelines.

## Project Structure

```
app/
├── controllers/        # Thin controllers with minimal logic
│   ├── concerns/       # Reusable controller concerns
│   └── ...
├── models/             # Rich domain models
│   └── concerns/       # Reusable model concerns
├── views/              # ERB templates
│   ├── layouts/        # Application layouts
│   └── notes/          # Note views
├── javascript/         # Stimulus controllers
│   └── controllers/    # Auto-save and other JS interactions
└── assets/             # Stylesheets and static assets

config/
├── routes.rb           # RESTful routes
├── database.yml        # Database configuration
└── locales/            # i18n translations

db/
├── migrate/            # Database migrations
└── schema.rb           # Current database schema

docs/
├── STYLE.md            # Comprehensive style guide
└── AI_INSTRUCTIONS.md  # AI development guidelines

test/
├── models/             # Model tests
├── controllers/        # Controller tests
├── system/             # System/integration tests
└── fixtures/           # Test data fixtures
```

## Database Schema

### Core Models

- **User** - Authentication and user preferences (dark mode)
- **Note** - Notes with title, rich content, color, and pinning
- **Tag** - Categories for organizing notes
- **Tagging** - Join table for notes and tags
- **SharedWith** - Sharing notes between users
- **Connection** - User-to-user relationships
- **Device** - Push notification device registration

## Roadmap

### Implemented ✅
- User authentication and registration
- Note CRUD with rich text editing
- Color coding (22 colors)
- Pin/unpin functionality
- Auto-save with Stimulus
- Dark mode preference
- Responsive design
- i18n support

### Planned 🚧
- Tag management UI
- Note sharing between users
- User connections/contacts
- Push notifications
- Change tracking/version history
- Hotwire Native mobile apps
- Search functionality
- Export/import notes
- Two-factor authentication

## Contributing

1. Follow the style guide in [`docs/STYLE.md`](docs/STYLE.md)
2. Write tests for new features
3. Ensure Rubocop passes
4. All user-facing strings must be i18n'd
5. Keep changes focused and minimal

## Architecture Decisions

### Why SQLite3?
- Simple development setup
- Perfect for single-user or small team usage
- Easy to migrate to PostgreSQL for production if needed

### Why Hotwire over React?
- Simpler mental model
- Less JavaScript to maintain
- Better SEO out of the box
- Faster initial page loads
- Aligns with Rails philosophy

### Why Vanilla Rails?
- Easier to upgrade Rails versions
- Fewer dependencies to maintain
- Better for new Rails developers
- Leverages Rails conventions
- No Node.js required (importmap + standalone Tailwind)
- Minimal infrastructure requirements
- Every dependency is a potential point of failure

## License

This project follows standard open source practices.

## Acknowledgments

- Inspired by Google Keep
- Style guide influenced by Basecamp's Fizzy project
- Built with the vanilla Rails philosophy
