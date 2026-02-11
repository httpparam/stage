class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :demo_url
      t.string :github_url
      t.text :description
      t.references :event, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :projects, :event_id
  end
end
