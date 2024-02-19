class AddMemberInfoColumns < ActiveRecord::Migration
  def change
    add_column :user_infos, :work_category, :string, after: :work_history
    add_column :user_infos, :origin, :string, before: :ethnicity
    add_column :user_infos, :lifestyle, :string
    add_column :user_infos, :linkedin_link, :text
  end
end
