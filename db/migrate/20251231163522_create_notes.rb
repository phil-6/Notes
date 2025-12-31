class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :color, default: "default"
      t.boolean :pinned, default: false, null: false

      t.timestamps
    end
    add_index :notes, :pinned
  end
end
