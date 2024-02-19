require 'rails_helper'

RSpec.describe Reservation, :type => :model do
  let(:reservation) { Fabricate(:reservation) }

  it 'has a valid factory' do
    expect(reservation).to be_valid
  end
end
