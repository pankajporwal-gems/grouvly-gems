require 'rails_helper'

RSpec.describe Admin::MatchesController, :type => :controller do

  before do
    login_admin
  end

  describe 'GET #index' do
    context 'when there is no location' do
      before do
        get :index
      end

      it { expect(response).to have_http_status(:success) }
    end

    context 'when there is a location' do
      before do
        get :index, location: APP_CONFIG['available_locations'].sample
      end

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'GET #show' do
    context 'when there is a schedule' do
      before do
        get :show, id: APP_CONFIG['available_locations'].sample, date: Chronic.parse('today')
      end

      it { expect(response).to have_http_status(:success) }
    end
  end
end