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

ActiveRecord::Schema[7.0].define(version: 2023_07_21_231422) do
  create_table "journee_completes", id: :integer, charset: "utf8", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "journees", id: :integer, charset: "utf8", force: :cascade do |t|
    t.date "date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["date"], name: "index_journees_on_date", unique: true
  end

  create_table "mesures", id: :integer, charset: "utf8", force: :cascade do |t|
    t.integer "journee_id"
    t.string "indicateur", default: "", null: false
    t.decimal "valeur", precision: 8, scale: 3, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "temps", precision: nil
    t.integer "user_id", default: 0
  end

  create_table "users", id: :integer, charset: "utf8", force: :cascade do |t|
    t.string "courriel"
    t.string "nom"
    t.string "roles"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["courriel"], name: "index_users_on_courriel"
    t.index ["courriel"], name: "users_unique_courriel", unique: true
  end

end
