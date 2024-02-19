require 'rails_helper'

RSpec.describe MatchedReservation, :type => :model do
  let(:matched_reservation) { Fabricate(:matched_reservation) }

  it 'has a valid factory' do
    expect(matched_reservation).to be_valid
  end
end
