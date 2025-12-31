class AddStatusToConnections < ActiveRecord::Migration[8.1]
  def change
    add_column :connections, :status, :string, default: "pending", null: false
    add_index :connections, :status
  end
end
