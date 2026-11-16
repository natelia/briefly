# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_10_152839) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "articles", force: :cascade do |t|
    t.bigint "source_id", null: false
    t.string "title", null: false
    t.string "url", null: false
    t.text "summary"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id"], name: "index_articles_on_source_id"
    t.index ["url"], name: "index_articles_on_url", unique: true
  end

  create_table "briefings", force: :cascade do |t|
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_briefings_on_date", unique: true
  end

  create_table "concept_cards", force: :cascade do |t|
    t.bigint "briefing_id", null: false
    t.string "title"
    t.string "domain"
    t.text "what_it_is"
    t.text "how_it_works"
    t.text "why_you_care"
    t.string "deeper_link"
    t.string "series_name"
    t.integer "series_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["briefing_id"], name: "index_concept_cards_on_briefing_id"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.bigint "briefing_id", null: false
    t.text "question"
    t.jsonb "options"
    t.integer "answer_index"
    t.text "explanation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["briefing_id"], name: "index_quiz_questions_on_briefing_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "name", null: false
    t.string "feed_url", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feed_url"], name: "index_sources_on_feed_url", unique: true
  end

  create_table "stories", force: :cascade do |t|
    t.bigint "briefing_id", null: false
    t.integer "section", null: false
    t.string "title"
    t.string "source_name"
    t.string "url"
    t.text "summary"
    t.text "why_it_matters"
    t.boolean "stretch", default: false, null: false
    t.datetime "read_at"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "digest"
    t.bigint "article_id"
    t.index ["article_id"], name: "index_stories_on_article_id"
    t.index ["briefing_id"], name: "index_stories_on_briefing_id"
  end

  add_foreign_key "articles", "sources"
  add_foreign_key "concept_cards", "briefings"
  add_foreign_key "quiz_questions", "briefings"
  add_foreign_key "stories", "articles"
  add_foreign_key "stories", "briefings"
end
