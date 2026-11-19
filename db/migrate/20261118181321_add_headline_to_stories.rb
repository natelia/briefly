class AddHeadlineToStories < ActiveRecord::Migration[8.1]
  def change
    add_column :stories, :headline, :string
  end
end
