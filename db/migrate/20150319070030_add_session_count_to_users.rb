class AddSessionCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :session_count, :integer, default: 0
  end
end
