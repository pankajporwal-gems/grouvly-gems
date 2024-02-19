class SetEmailAddressNotNullToFalseUserInfo < ActiveRecord::Migration
  def change
    change_column_null :user_infos, :email_address, true
  end
end
