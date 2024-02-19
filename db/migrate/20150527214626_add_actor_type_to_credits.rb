class AddActorTypeToCredits < ActiveRecord::Migration
  def change
    add_column :credits, :actor_type, :string, null: false, default: 'User'
  end
end
