class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  # rescue_from Koala::Facebook::AuthenticationError do |exception|
  #   if current_user
  #     reset_session
  #     redirect_to root_url
  #   end
  # end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    reset_session
    redirect_to root_url
  end

  rescue_from ActionController::RoutingError do |exception|
    redirect_to root_url, alert: exception.message
  end

  def handle_unverified_request
    forgery_protection_strategy.new(self).handle_unverified_request
    reset_session
    redirect_to root_url
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def current_admin
    id = session[:admin_id]
    first_name = session[:admin_first_name]
    last_name = session[:admin_last_name]
    photo = session[:admin_photo]

    @current_admin ||= { id: id, first_name: first_name, last_name: last_name, photo: photo }

    if (ENV['ADMINS'] || "").split(',').include?(id)
      @current_admin['role'] = 'admin'
    elsif (ENV['MATCHERS'] || "").split(',').include?(id)
      @current_admin['role'] = 'matcher'
    else
      @current_admin = nil
    end

    @current_admin
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def graph
    @graph ||= Koala::Facebook::API.new(current_user.oauth_token)
  end

  def me
    @me ||= graph.get_object('me')
  end

  def referrer
    @referrer ||= User.where(code: referral_code).first if referral_code.present?
  end

  def fee
    @fee ||= if APP_CONFIG['fee'][current_location]
      APP_CONFIG['fee'][current_location][user_gender]
    else
      APP_CONFIG['fee'][APP_CONFIG['fee_default']][user_gender]
    end
  end

  def currency
    @currency ||= if APP_CONFIG['fee_currency'][current_location]
      APP_CONFIG['fee_currency'][current_location]
    else
      APP_CONFIG['fee_currency'][APP_CONFIG['fee_default']]
    end
  end

  def referral_reward
    @referral_reward ||= APP_CONFIG['referral_reward'][current_location]
  end

  def referral_currency
    @referral_currency ||= APP_CONFIG['referral_currency'][current_location]
  end

  def referral_program_enabled?
    @referral_program_enabled ||= APP_CONFIG['referral_program_start_date'][current_location].present? &&
      APP_CONFIG['referral_program_start_date'][current_location] <= Chronic.parse('now')
  end

  def page_presenter
    @page_presenter ||= PagePresenter.new(current_user || nil, referrer)
  end

  def support_email
    @support_email ||= APP_CONFIG['support_email']
  end

  helper_method :current_admin
  helper_method :current_user
  helper_method :graph
  helper_method :me
  helper_method :referrer
  helper_method :fee
  helper_method :currency
  helper_method :referral_reward
  helper_method :referral_currency
  helper_method :referral_program_enabled?
  helper_method :page_presenter
  helper_method :support_email

  private

  def user_gender
    gender = if current_user.present?
              current_user.gender
            else
              'male'
            end
  end

  def referral_code
    @referral_code ||= if action_name == 'join' && controller_name == 'pages'
      params[:id]
    elsif session[:grouvly_referral_url].present?
      session[:grouvly_referral_url].split('/').last
    end
  end

  def current_location
    if current_user.present?
      @current_location ||= current_user.location
    elsif params[:location].blank?
      @current_location ||= if Rails.env.test? || Rails.env.development?
        Geocoder.search('219.75.27.16').first.data[:country_name]
      elsif request.location
        request.location.data[:country_name]
      end
    else
      @current_location ||= Geocoder.search(params[:location]).first.data['formatted_address'] rescue params[:location]
    end
  end
end
