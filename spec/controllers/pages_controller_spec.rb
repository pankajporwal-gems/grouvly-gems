require 'rails_helper'

RSpec.describe PagesController, :type => :controller do
  describe 'GET #index' do
    context 'when user is logged in' do
    end

    context 'when user is not logged in' do
      before do
        get :index
      end

      it { is_expected.to render_template :index }
      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'GET #why-facebook' do
    before do
      get 'why_facebook'
    end

    it { is_expected.to render_template 'why_facebook' }
    it { expect(response).to have_http_status(:success) }
  end

  describe 'GET #how-it-works' do
    before do
      get 'how_it_works'
    end

    it { is_expected.to render_template 'how_it_works' }
    it { expect(response).to have_http_status(:success) }
  end

  describe 'GET #faq' do
    before do
      get 'faq'
    end

    it { is_expected.to render_template 'faq' }
    it { expect(response).to have_http_status(:success) }
  end

  describe 'GET #privacy-policy' do
    before do
      get 'privacy_policy'
    end

    it { is_expected.to render_template 'privacy_policy' }
    it { expect(response).to have_http_status(:success) }
  end

  describe 'GET #about-us' do
    before do
      get 'about_us'
    end

    it { is_expected.to render_template 'about_us' }
    it { expect(response).to have_http_status(:success) }
  end

  describe 'GET #terms-of-service' do
    before do
      get 'terms_of_service'
    end

    it { is_expected.to render_template 'terms_of_service' }
    it { expect(response).to have_http_status(:success) }
  end

  describe 'GET #contact-us' do
    before do
      get 'contact_us'
    end

    it { is_expected.to render_template 'contact_us' }
    it { expect(response).to have_http_status(:success) }
    it { expect(assigns(:available_message_about)).to eq(APP_CONFIG['available_message_about']) }
    it { expect(assigns(:inquiry)).to be_kind_of(Inquiry) }
  end

  describe 'POST #contact-us' do
    context 'with valid attributes' do
      let(:inquiry) { Fabricate.attributes_for(:inquiry) }

      before do
        post 'contact_us', { inquiry: inquiry, commit: I18n.t('pages.contact_us.send') }
      end

      it { expect(flash[:notice]).to eq(I18n.t('pages.contact_us.your_inquiry_has_been_submitted')) }

      it 'should send an email' do
        mock(SendInquiryJob)
      end
    end

    context 'with invalid attributes' do
      before do
        post 'contact_us', { inquiry: { name: '' }, commit: I18n.t('pages.contact_us.send') }
      end

      it { expect(flash[:notice]).to be_nil }
    end
  end

  describe 'GET #bars-and-venues' do
    before do
      get 'bars_and_venues'
    end

    it { is_expected.to render_template 'bars_and_venues' }
    it { expect(response).to have_http_status(:success) }
    it { expect(assigns(:inquiry)).to be_kind_of(Inquiry) }
  end

  describe 'POST #bars-and-venues' do
    context 'with valid attributes' do
      let(:inquiry) { Fabricate.attributes_for(:inquiry) }

      before do
        post 'contact_us', { inquiry: inquiry, commit: I18n.t('pages.contact_us.send') }
      end

      it { expect(flash[:notice]).to eq(I18n.t('pages.contact_us.your_inquiry_has_been_submitted')) }

      it 'should send an email' do
        mock(SendInquiryJob)
      end
    end

    context 'with invalid attributes' do
      before do
        post 'contact_us', { inquiry: { name: '' }, commit: I18n.t('pages.contact_us.send') }
      end

      it { expect(flash[:notice]).to be_nil }
    end
  end
end
