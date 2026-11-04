class CreateConceptCards < ActiveRecord::Migration[8.1]
  def change
    create_table :concept_cards do |t|
      t.references :briefing, null: false, foreign_key: true
      t.string :title
      t.string :domain
      t.text :what_it_is
      t.text :how_it_works
      t.text :why_you_care
      t.string :deeper_link
      t.string :series_name
      t.integer :series_position

      t.timestamps
    end
  end
end
