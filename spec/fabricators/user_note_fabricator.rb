Fabricator(:user_note) do
  user { Fabricate(:user) }
  content { Faker::Number.number(2)}
end
