class AddCanEditToSharedWiths < ActiveRecord::Migration[8.1]
  def change
    add_column :shared_withs, :can_edit, :boolean, default: false, null: false
  end
end
