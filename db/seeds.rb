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

user = User.create(provider: "facebook", first_name: "Test", last_name: "User", oauth_token: "fsdjlkfjlkd2143251453dfdfd", oauth_expires_at: "2024-04-21 10:33:39.959555", slug: "1456352fsdfs", uid: "124578965352dfdfd58")

#User transition
ut1 = UserTransition.create(to_state: "pending", metadata: { occured_on: Time.now }.to_json, sort_key: 0, user_id: user.id)
ut2 = UserTransition.create(to_state: "accepted", metadata: { "occured_on" => Time.now, "performed_by" => admin }.to_json, sort_key: 1, user_id: user.id)

user_info = user.build_user_info(
  email_address: "testuser@example.com",
  gender_to_match: "female",
  location: "Singapore",
  phone: "12345678",
  current_work: "Developer",
  studied_at: "IIST",
  religion: "Hinduism",
  height: "5",
  gender: "male",
  current_employer: "Gems Essence",
  hometown: "India",
  ethnicity: "Indian",
  hang_out_with: "Everyone",
  native_place: "India"
)
user_info.save

10.times do
  new_user = User.create(
    provider: "facebook",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    oauth_token: Faker::Internet.password(30),
    oauth_expires_at: Time.now + 60.days,
    slug: Faker::Internet.password(12),
    uid: Faker::Internet.password(20)
  )

  UserTransition.create(to_state: "pending", metadata: { occured_on: Time.now }.to_json, sort_key: 0, user_id: new_user.id)
end
