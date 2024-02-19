Fabricator(:user) do
  provider { 'facebook' }
  uid { Faker::Number.number(16) }
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  oauth_token { Faker::Number.number(100) }
  oauth_expires_at { Faker::Time.forward(60, :all) }
end
