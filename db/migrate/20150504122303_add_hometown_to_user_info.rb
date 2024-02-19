class AddHometownToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :hometown, :string
  end
end
