class CreateEventParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :event_participants do |t|
      t.references :event, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true, index: false
      t.boolean :is_admin, default: false, null: false

      t.timestamps
    end

    add_index :event_participants, [:event_id, :user_id], unique: true
  end
end
