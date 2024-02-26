class UserCreator
  include ActiveModel::Model

  attr_reader :user

  def initialize(auth, referrer, sources)
    # @user ||= User.where(provider: auth.provider, uid: auth.uid).first
    # @user ||= User.where(provider: auth.provider, uid: auth.uid).first
    # @auth ||= auth
    # @referrer ||= referrer
    # @sources ||= sources
    @user = User.new
  end

  def process_user
    if @user.blank?
      create_user
    else
      save_user
      save_referrer if (@user.new? || @user.wing?) && @user.referrer.blank?
    end
  end

  private

  def get_access_token
    # immediately get 60 day auth token
    oauth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"])
    @new_access_token ||= oauth.exchange_access_token_info(@auth.credentials.token)
  end

  def get_access_token_expiration
    @new_access_expires_at ||= DateTime.now + get_access_token['expires'].to_i.seconds
  end

  def generate_user_code
    Grouvly::Slug.generate(@user.id + APP_CONFIG['start_id'])
  end

  def save_referrer
    if @referrer && @referrer.referrals.where(id: @user.id).count == 0
      referral = @referrer.referrals.build({ referral_id: @user.id })
      referral.save!
    end
  end

  def set_acquisition_sources
    if @sources.is_a?(Hash)
      @user.acquisition_source = @sources['source']
      @user.acquisition_channel = @sources['medium']
    end
  end

  def create_user
    @user = User.new
    @user.provider = @auth.provider
    @user.uid = @auth.uid
    save_user
    save_referrer
    set_acquisition_sources
    @user.new!
    @user.update_attributes({ code: generate_user_code })
    set_user_info
  end

  def save_user
    @user.first_name = @auth.info.first_name
    @user.last_name = @auth.info.last_name
    @user.oauth_token = get_access_token['access_token']
    @user.oauth_expires_at = get_access_token_expiration
    @user.save!
  end

  def user_info
    @user_info ||= @user.build_user_info
  end

  def user_info_setter
    @user_info_setter ||= UserInfoSetter.new(user_info)
  end

  def set_user_info
    user_info_setter.set_default_values(@auth.extra.raw_info)
    user_info_setter.set_gender(@auth.extra.raw_info)
    user_info_setter.set_education(@auth.extra.raw_info)
    user_info_setter.set_work(@auth.extra.raw_info)
    user_info_setter.set_birthday(@auth.extra.raw_info) if @auth.extra.raw_info['birthday']
    user_info.save!(validate: false)
  end
end
