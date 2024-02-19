class EnableNullInCurrentCompany < ActiveRecord::Migration
  def change
    change_column :user_infos, :current_employer, :string, null: true
  end
end
