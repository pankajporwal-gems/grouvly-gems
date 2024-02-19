class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string    :name, null: false
      t.string    :venue_type, null: false
      t.string    :location, null: false
      t.string    :neighborhood, null: false
      t.string    :owner_name, null: false
      t.string    :owner_email, null: false
      t.string    :owner_phone, null: false
      t.string    :manager_name, null: false
      t.string    :manager_email, null: false
      t.string    :manager_phone, null: false
      t.boolean   :is_free, null: false, default: false
      t.text      :map_link, null: false
      t.text      :directions, null: false
      t.integer   :capacity, null: false
      t.hstore    :booking_availability, null: false, default: ''
      t.text      :note

      t.timestamps null: false
      t.datetime  :deleted_at
    end
  end
end
