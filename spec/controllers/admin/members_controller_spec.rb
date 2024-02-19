require 'rails_helper'

RSpec.describe Admin::MembersController, :type => :controller do
  render_views

  before do
    login_admin
  end

  describe 'GET #index' do
    context 'when there is no location' do
      before do
        get :index
      end

      it { is_expected.to render_template :partial => '_summary' }
      it { expect(response).to have_http_status(:success) }
    end

    context 'when there is a location' do
      before do
        get :index, location: APP_CONFIG['available_locations'].sample
      end

      it { is_expected.to render_template :partial => '_list' }
      it { expect(response).to have_http_status(:success) }
    end

  end
end