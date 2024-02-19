Fabricator(:matched_reservation) do
  first_reservation { Fabricate(:reservation) }
  second_reservation { Fabricate(:reservation) }
end
