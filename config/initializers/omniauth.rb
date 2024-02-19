#require 'omniauth-openid'
#require 'openid'
#require 'openid/store/filesystem'
#require 'gapps_openid'

OmniAuth.config.logger = Rails.logger
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

OpenID.fetcher.ca_file = ENV['GROUVLY_WEBAPP_SSL_CERT_PATH'] if Rails.env == 'production'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
    provider_ignores_state: true, scope: APP_CONFIG['facebook_permissions'], info_fields: "id, name, first_name, middle_name, last_name, age_range, link, gender, locale, timezone, updated_time, verified, email, birthday, location", display: 'popup',
    callback_url: ENV['FACEBOOK_CALLBACK_URL']

  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], name: 'admin'

  #provider :open_id, name: 'admin', identifier: 'https://www.google.com/accounts/o8/site-xrds?hd=grouvly.com',
    #:store => OpenID::Store::Filesystem.new('/tmp')
end
