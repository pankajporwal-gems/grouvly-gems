class AddSlugToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :slug, :string
    add_index :reservations, :slug
  end
end
