class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :project, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :votes, [:user_id, :project_id], unique: true
    add_index :votes, :project_id
  end
end
