class AddDigestToStories < ActiveRecord::Migration[8.1]
  def change
    add_column :stories, :digest, :text
  end
end
