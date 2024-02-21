class PagePresenter
  attr_reader :user

  def initialize(user, referrer)
    @user ||= user
    @referrer ||= referrer
    @app_id ||= ENV['FACEBOOK_APP_ID']
    @app_secret ||= ENV['FACEBOOK_APP_SECRET']
    @callback_url ||= ENV['FACEBOOK_CALLBACK_URL']
    @permissions ||= APP_CONFIG['facebook_permissions']
    @oauth ||= Koala::Facebook::OAuth.new(@app_id, @app_secret, @callback_url)
  end

  def login_url
    # if @user.present?
    #   Rails.application.routes.url_helpers.user_root_path
    # else
    #   @oauth.url_for_oauth_code({ permissions: @permissions })
    
    # end
    Rails.application.routes.url_helpers.new_user_login_path
  end

  def referrer_name
    if @referrer.present?
      user_decorator = UserDecorator.new(@referrer)
      user_decorator.name
    end
  end

  def referrer_small_picture
    @referrer.small_profile_picture if @referrer.present?
  end

  def referrer_normal_picture
    @referrer.normal_profile_picture if @referrer.present?
  end

  def referrer_reward_amount
    APP_CONFIG['referral_reward'][@referrer.location]
  end

  def referrer_reward_currency
    APP_CONFIG['referral_currency'][@referrer.location]
  end
end
