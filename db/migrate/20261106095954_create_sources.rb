class CreateSources < ActiveRecord::Migration[8.1]
  def change
    create_table :sources do |t|
      t.string :name, null: false
      t.string :feed_url, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :sources, :feed_url, unique: true
  end
end
