class CreateStories < ActiveRecord::Migration[8.1]
  def change
    create_table :stories do |t|
      t.references :briefing, null: false, foreign_key: true
      t.integer :section, null: false
      t.string :title
      t.string :source_name
      t.string :url
      t.text :summary
      t.text :why_it_matters
      t.boolean :stretch, default: false, null: false
      t.datetime :read_at
      t.datetime :published_at

      t.timestamps
    end
  end
end
