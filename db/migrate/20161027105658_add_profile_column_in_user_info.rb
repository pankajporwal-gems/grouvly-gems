class AddProfileColumnInUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :neighborhoods, :string
    add_column :user_infos, :meet_new_people_ages, :string
    add_column :user_infos, :typical_weekends, :string
  end
end
