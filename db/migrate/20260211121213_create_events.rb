class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description
      t.date :event_date
      t.string :invite_code, null: false
      t.references :user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :events, :invite_code, unique: true
    add_index :events, :user_id
  end
end
