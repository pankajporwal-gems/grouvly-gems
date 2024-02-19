module AdminControllerHelpers
  def login_admin
    request.env['omniauth.auth'] = mock_google_auth

    user = request.env['omniauth.auth']['info']
    session[:admin_id] = user['email']
    session[:admin_first_name] = user['first_name']
    session[:admin_last_name] = user['last_name']
    session[:admin_photo] = user['image']
  end

  def mock_google_auth
    admin_user = Fabricate.attributes_for(:admin_user)

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: admin_user[:uid],
      info: OmniAuth::AuthHash::InfoHash.new({
        email: admin_user[:email],
        first_name: admin_user[:first_name],
        last_name: admin_user[:last_name],
        image: admin_user[:image]
      })
    })
  end
end