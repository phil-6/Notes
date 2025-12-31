class CreateNoteVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :note_versions do |t|
      t.references :note, null: false, foreign_key: true, index: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }, index: true
      t.text :title
      t.text :content
      t.string :color
      t.integer :version_number, null: false
      t.string :change_type, default: "updated", null: false

      t.timestamps
    end

    add_index :note_versions, [ :note_id, :version_number ], unique: true
  end
end
