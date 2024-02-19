class RemoveNotNullConstraintsInUserInfo < ActiveRecord::Migration
  def change
    change_column_null :user_infos, :gender_to_match, true
    change_column_null :user_infos, :location, true
    change_column_null :user_infos, :phone, true
    change_column_null :user_infos, :current_work, true
    change_column_null :user_infos, :studied_at, true
    change_column_null :user_infos, :religion, true
    change_column_null :user_infos, :importance_of_religion, true
    change_column_null :user_infos, :ethnicity, true
    change_column_null :user_infos, :importance_of_ethnicity, true
    change_column_null :user_infos, :neighborhood, true
    change_column_null :user_infos, :height, true
    change_column_null :user_infos, :birthday, true
    change_column_null :user_infos, :gender, true
  end
end
