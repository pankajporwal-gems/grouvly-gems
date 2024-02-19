class CreateUserInfos < ActiveRecord::Migration
  def change
    create_table :user_infos do |t|
      t.belongs_to :user, null: false
      t.string   :email_address, null: false
      t.string   :gender_to_match, null: false
      t.string   :location, null: false
      t.string   :phone, null: false
      t.string   :drinks, null: false
      t.string   :current_work, null: false
      t.string   :studied_at, null: false
      t.string   :religion, null: false
      t.string   :importance_of_religion, null: false
      t.string   :ethnicity, null: false
      t.string   :importance_of_ethnicity, null: false
      t.string   :neighborhood, null: false
      t.integer  :height, null: false
      t.datetime :last_facebook_update
      t.string   :small_profile_picture
      t.string   :normal_profile_picture
      t.string   :large_profile_picture
      t.date     :birthday, null: false
      t.json     :work_history
      t.json     :education_history
      t.json     :likes
      t.string   :gender, null: false
      t.string   :current_employer, null: false

      t.timestamps null: false
    end

    add_foreign_key :user_infos, :users
    add_index :user_infos, :user_id
  end
end
