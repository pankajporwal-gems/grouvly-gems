require 'rails_helper'

RSpec.describe UserInfo, :type => :model do
  let(:user_note) { Fabricate(:user_note) }

  it 'has a valid factory' do
    expect(user_note).to be_valid
  end

  it 'is invalid without a content' do
    invalid_user_note = UserNote.new(user_note.attributes.except('content'))
    expect(invalid_user_note).not_to be_valid
  end
end
