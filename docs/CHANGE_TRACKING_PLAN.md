# Change Tracking Implementation Plan

## Context
We want to track all changes to notes, allowing users to:
- View version history
- See who made changes (important for shared notes)
- Restore previous versions
- Compare versions (future enhancement)

## Simple Solutions (Ranked by Complexity)

### Option 1: Simple Versions Table ⭐ RECOMMENDED
**Philosophy**: Store complete snapshots of each version

**Schema**:
```ruby
create_table :note_versions do |t|
  t.references :note, null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.text :title
  t.text :content  # We'll store the ActionText content
  t.string :color
  t.integer :version_number, null: false
  t.string :change_type  # 'created', 'updated', 'shared', 'unshared'
  t.timestamps
end

add_index :note_versions, [:note_id, :version_number], unique: true
```

**Pros**:
- Simple to understand and implement
- Complete snapshot = easy to restore
- No dependencies (pure Rails)
- Fast reads (no reconstruction needed)

**Cons**:
- More storage space (but SQLite compresses well)
- Doesn't track ActionText attachments (we can handle separately if needed)

**Implementation**:
- Use `after_save` callback on Note
- Create version on each update
- Store who made the change
- Auto-increment version number

---

### Option 2: Delegated Type Pattern (37signals Style)
**Philosophy**: Use delegated_type to distinguish current vs historical

**Schema**:
```ruby
# Polymorphic base table
create_table :note_records do |t|
  t.references :user, null: false, foreign_key: true
  t.text :title
  t.text :content
  t.string :color
  t.string :record_type, null: false  # 'Note::Current' or 'Note::Version'
  t.references :recordable, polymorphic: true, null: false
  t.timestamps
end

# Current note (what user sees)
create_table :note_currents do |t|
  t.boolean :pinned, default: false
  t.timestamps
end

# Historical versions
create_table :note_histories do |t|
  t.references :note_current, null: false, foreign_key: true
  t.integer :version_number, null: false
  t.string :change_type
  t.timestamps
end
```

**Model Structure**:
```ruby
class NoteRecord < ApplicationRecord
  delegated_type :recordable, types: %w[Note::Current Note::History]
end

class Note::Current < ApplicationRecord
  has_one :note_record, as: :recordable, touch: true
  has_many :note_histories
end

class Note::History < ApplicationRecord
  has_one :note_record, as: :recordable
  belongs_to :note_current
end
```

**Pros**:
- Clean separation of current vs historical
- 37signals approved pattern
- Scalable architecture
- Still vanilla Rails (no gems)

**Cons**:
- More complex to understand
- More tables and joins
- Migrations are bigger changes to existing system

---

### Option 3: Event Sourcing Light
**Philosophy**: Store changes as deltas/events

**Schema**:
```ruby
create_table :note_events do |t|
  t.references :note, null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.string :event_type  # 'title_changed', 'content_changed', 'color_changed'
  t.text :old_value
  t.text :new_value
  t.integer :version_number
  t.timestamps
end
```

**Pros**:
- Smallest storage footprint
- Can see exact what changed
- Event-driven architecture

**Cons**:
- Must reconstruct state from events (slow)
- More complex queries
- Harder to restore to exact version

---

## Recommendation: Option 1 (Simple Versions Table)

### Why?
1. ✅ **Vanilla Rails** - No gems, pure ActiveRecord
2. ✅ **Simple to understand** - Junior devs can maintain
3. ✅ **Fast reads** - No reconstruction needed
4. ✅ **Easy restore** - Just copy data back
5. ✅ **Minimal refactoring** - Works with existing Note model

### Implementation Plan

**Step 1**: Migration
- Create `note_versions` table
- Add indexes for performance

**Step 2**: Model
```ruby
class Note < ApplicationRecord
  has_many :versions, class_name: "NoteVersion", dependent: :destroy

  after_save :create_version, unless: :skip_versioning
  attr_accessor :skip_versioning

  def restore_version(version)
    self.skip_versioning = true
    update(
      title: version.title,
      content: version.content,
      color: version.color
    )
    self.skip_versioning = false
  end
end

class NoteVersion < ApplicationRecord
  belongs_to :note
  belongs_to :user

  # Store ActionText content as JSON
  def content=(value)
    super(value.to_s) if value.respond_to?(:to_s)
  end
end
```

**Step 3**: Controller
- Track Current.user who made changes
- Add version history view
- Add restore action

**Step 4**: Views
- Version history timeline
- Restore button
- Show who made each change

### Storage Considerations

For a note with:
- Title: ~50 chars
- Content: ~1000 chars
- Metadata: ~50 chars

**Per version**: ~1.1 KB
**100 versions**: ~110 KB
**1000 versions**: ~1.1 MB

SQLite handles this efficiently with compression.

---

## Alternative: If We Want to Avoid Versions Table

We could use ActionText's built-in `RichText` versioning:
- Store ActionText content history separately
- Less invasive to existing schema
- But doesn't track title/color changes

---

## Decision Needed

Which approach should we implement?

**My recommendation**: Option 1 (Simple Versions Table)
- Aligns with vanilla Rails philosophy
- No gems needed
- Simple to understand and maintain
- Easy to implement
- Sufficient for our use case

Would you like me to implement this approach?
