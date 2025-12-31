class CreateConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :connections do |t|
      t.bigint :user_1_id, null: false
      t.bigint :user_2_id, null: false

      t.timestamps
    end
    add_index :connections, :user_1_id
    add_index :connections, :user_2_id
    add_index :connections, [ :user_1_id, :user_2_id ], unique: true
    add_foreign_key :connections, :users, column: :user_1_id
    add_foreign_key :connections, :users, column: :user_2_id
  end
end
