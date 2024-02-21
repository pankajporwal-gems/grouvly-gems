# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# unless Rails.env.production?
#   connection = ActiveRecord::Base.connection
#   #connection.tables.each do |table|
#   #  connection.execute("TRUNCATE #{table}") unless table == "schema_migrations"
#   #end

#   sql = File.read('db/grouvly_production_two.sql')
#   statements = sql.split(/;$/)
#   statements.pop

#   ActiveRecord::Base.transaction do
#     statements.each do |statement|
#       connection.execute(statement)
#     end
#   end
# end

admin = {
  "id" => 1,
  "email" => 'admin@example.com',
  "first_name" => 'Admin',
  "last_name" => 'User'
}

user = User.create(provider: "facebook", first_name: "Example", last_name: "User", oauth_token: "fsdjlkfjlkd2143251453dfdfd", oauth_expires_at: "2024-04-21 10:33:39.959555", slug: "Example-1456352f-sdfsf", uid: "124578965352dfdfd58")

#User transition
ut1 = UserTransition.create(to_state: "pending", metadata: { occured_on: Time.now }.to_json, sort_key: 0, user_id: user.id)
ut2 = UserTransition.create(to_state: "accepted", metadata: { "occured_on" => Time.now, "performed_by" => admin }.to_json, sort_key: 1, user_id: user.id)

user.create_user_info(email_address: "pankaj.porwal@gemsessence.com", gender_to_match: "female", location: "Singapore", phone: "12345678", current_work: "Developer", studied_at: "IIST", religion: "Hinduism", height: "5", gender: "male", current_employer: "Gems Essence", hometown: "India", typical_weekend: "Stay at home", ethnicity: "Indian", hang_out_with: "Everyone", meet_new_people_age: ['20s', '30s'])

