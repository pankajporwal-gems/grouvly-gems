class AddColumnInUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :meet_new_people_age, :string
    add_column :user_infos, :native_place, :string
    add_column :user_infos, :hang_out_with, :string
    add_column :user_infos, :typical_weekend, :string
  end
end
