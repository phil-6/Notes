class AddPositionToNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :notes, :position, :integer, default: 0, null: false
    add_index :notes, :position

    # Set initial positions for existing notes
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE notes
          SET position = id
          WHERE position = 0 OR position IS NULL
        SQL
      end
    end
  end
end
