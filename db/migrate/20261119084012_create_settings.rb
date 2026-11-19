class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.string :llm_api_key
      t.timestamps
    end
  end
end
