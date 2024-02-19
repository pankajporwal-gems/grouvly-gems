class RemoveDrinksFromUserInfos < ActiveRecord::Migration
  def change
    remove_column :user_infos, :drinks
  end
end
