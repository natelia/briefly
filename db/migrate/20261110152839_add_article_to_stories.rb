class AddArticleToStories < ActiveRecord::Migration[8.1]
  def change
    # null: true (the default) on purpose: stories that predate the pipeline
    # (seeded demo days) have no article behind them.
    add_reference :stories, :article, foreign_key: true
  end
end
