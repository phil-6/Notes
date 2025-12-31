class CreateSharedWiths < ActiveRecord::Migration[8.1]
  def change
    create_table :shared_withs do |t|
      t.references :note, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
