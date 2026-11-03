class CreateBriefings < ActiveRecord::Migration[8.1]
  def change
    create_table :briefings do |t|
      t.date :date, null: false

      t.timestamps
    end
    add_index :briefings, :date, unique: true
  end
end
