require 'rails_helper'

RSpec.describe Venue, :type => :model do
  let(:venue) { Fabricate(:venue) }

  it 'has a valid factory' do
    expect(venue).to be_valid
  end

  it 'is invalid without a name' do
    invalid_venue = Venue.new(venue.attributes.except('name'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without a venue type' do
    invalid_venue = Venue.new(venue.attributes.except('venue_type'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without a location' do
    invalid_venue = Venue.new(venue.attributes.except('location'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without a neighborhood' do
    invalid_venue = Venue.new(venue.attributes.except('neighborhood'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without an owner name' do
    invalid_venue = Venue.new(venue.attributes.except('owner_name'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without an owner email' do
    invalid_venue = Venue.new(venue.attributes.except('owner_email'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without an owner phone number' do
    invalid_venue = Venue.new(venue.attributes.except('owner_phone'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without an booking manager name' do
    invalid_venue = Venue.new(venue.attributes.except('manager_name'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without an booking manager email' do
    invalid_venue = Venue.new(venue.attributes.except('manager_email'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without an booking manager phone number' do
    invalid_venue = Venue.new(venue.attributes.except('manager_phone'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without a link to a map' do
    invalid_venue = Venue.new(venue.attributes.except('map_link'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without directions to the venue' do
    invalid_venue = Venue.new(venue.attributes.except('directions'))
    expect(invalid_venue).not_to be_valid
  end

  it 'is invalid without a capacity number' do
    invalid_venue = Venue.new(venue.attributes.except('capacity'))
    expect(invalid_venue).not_to be_valid
  end
end

RSpec.describe Venue, '.destroy', :type => :model do
  it 'returns only active venues' do
    active_venue = Fabricate(:venue)
    inactive_venue = Fabricate(:venue)
    # Set deleted_at
    inactive_venue.destroy

    expect(Venue.all).to eq [active_venue]
  end
end
