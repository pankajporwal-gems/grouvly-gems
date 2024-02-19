class AddPhotosToUserInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :photos, :text, array: true, default: []
  end
end
