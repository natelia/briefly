class CreateQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_questions do |t|
      t.references :briefing, null: false, foreign_key: true
      t.text :question
      t.jsonb :options
      t.integer :answer_index
      t.text :explanation

      t.timestamps
    end
  end
end
