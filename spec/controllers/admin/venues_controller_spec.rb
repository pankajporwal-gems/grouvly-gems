require 'rails_helper'

RSpec.describe Admin::VenuesController, :type => :controller do
  before do
    login_admin
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it { expect(response).to have_http_status(:success) }
  end
end