Fabricator(:reservation) do
  user { Fabricate(:user) }
  schedule { Chronic.parse('next Thursday at 8pm') }
end
