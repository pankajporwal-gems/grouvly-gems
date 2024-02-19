require 'rails_helper'

RSpec.describe VenueBookingNotification, :type => :model do
  let(:venue_booking_notification) { Fabricate(:venue_booking_notification) }

  it 'has a valid factory' do
    expect(venue_booking_notification).to be_valid
  end

  it 'can be set as acknowledged' do
    venue_booking_notification.acknowledge!
    expect(venue_booking_notification.acknowledged).to eq(true)
  end
end
