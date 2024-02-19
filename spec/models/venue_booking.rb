require 'rails_helper'

RSpec.describe VenueBooking, :type => :model do
  let(:venue_booking) { Fabricate(:venue_booking) }

  it 'has a valid factory' do
    expect(venue_booking).to be_valid
  end
end
