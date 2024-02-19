Fabricator(:admin_user, from: :user) do
  uid { Faker::Number.number(8) }
  email { ENV['ADMINS'].split(',').sample }
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  image { Faker::Avatar.image }
end
