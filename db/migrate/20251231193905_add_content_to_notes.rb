class AddContentToNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :notes, :content, :text
  end
end
