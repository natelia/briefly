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

ActiveRecord::Schema[8.1].define(version: 2026_11_04_142544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "briefings", force: :cascade do |t|
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_briefings_on_date", unique: true
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
    t.index ["briefing_id"], name: "index_stories_on_briefing_id"
  end

  add_foreign_key "quiz_questions", "briefings"
  add_foreign_key "stories", "briefings"
end
