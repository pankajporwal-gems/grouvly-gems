class AddCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :code, :string
    add_index :users, :code

    User.all.each do |user|
      code = UrlGenerator.generate_url(user.id + APP_CONFIG['start_id'])
      user.update_attributes({ code: code })
    end
  end
end
