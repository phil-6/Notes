class AddLockingToNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :notes, :locked_by_id, :integer
    add_column :notes, :locked_at, :datetime
    add_index :notes, :locked_by_id
    add_foreign_key :notes, :users, column: :locked_by_id
  end
end
