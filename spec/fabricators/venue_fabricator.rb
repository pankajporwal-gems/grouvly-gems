Fabricator(:venue) do
  name { Faker::Name.name }
  venue_type { APP_CONFIG['venue_types'].sample }
  location { APP_CONFIG['available_locations'].sample }
  neighborhood { APP_CONFIG['available_neighborhoods'][(APP_CONFIG['available_locations'].sample)].sample }
  owner_name { Faker::Name.name }
  owner_email { Faker::Internet.email }
  owner_phone { Faker::PhoneNumber.phone_number }
  manager_name { Faker::Name.name }
  manager_email { Faker::Internet.email }
  manager_phone { Faker::PhoneNumber.phone_number }
  map_link { Faker::Internet.url }
  directions { Faker::Lorem.paragraph }
  capacity { Faker::Number.number(2) }
  note { Faker::Lorem.paragraph }
end
