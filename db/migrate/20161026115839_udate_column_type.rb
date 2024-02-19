class UdateColumnType < ActiveRecord::Migration
  def up
    change_column :user_infos, :height, :string
  end
  def down
    change_column :user_infos, :height, 'integer USING CAST(height AS integer)'
  end
end
