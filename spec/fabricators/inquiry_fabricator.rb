Fabricator(:inquiry) do
  name { Faker::Name.name }
  email_address { Faker::Internet.email }
  phone { Faker::PhoneNumber.phone_number }
  message { Faker::Lorem.paragraph }
  what_is_message_about { APP_CONFIG['available_message_about'].sample }
  website { Faker::Internet.url }
end
