class SessionsController < ApplicationController
  include User::UserTracking

  def new_admin
  end
  
  def admin_login
    reset_session
    set_admin_session
    if current_admin
      redirect_to admin_root_url
    else
      reset_session
      redirect_to root_url
    end
  end

  def authenticate_admin
    reset_session
    set_admin_session

    if current_admin
      redirect_to admin_root_url
    else
      reset_session
      redirect_to root_url
    end
  end
  
  def new
    if current_user.present?
      redirect_to new_user_reservation_url
    elsif current_admin.present?
      redirect_to admin_root_url
    else
      @uid = User.includes(:user_info).where(user_infos: { id: nil }).pluck(:uid).join(', ')
    end
  end
  
  def create
    user = User.find_by(uid: params[:user][:uid])

    if user.present?
      reset_session
      if params[:user][:r].present?
        session[:join_grouvly_url] = params[:user][:r]
      end

      session[:user_id] = user.id
      increase_session_count(user)

      if user.user_info.blank?
        redirect_to new_user_membership_url
      else
        track_event(EVENT_LOGGED_IN)
        render_page_of_logged_in_user
      end
    else
      flash[:alert] = "User Not Found"
      render :new
    end
  end

  def destroy
    track_event(EVENT_LOGGED_OUT)
    reset_session
    # Clear cookie used to keep users logged in
    cookies.delete(:oauth_uid)

    redirect_to root_url
  end

  private

  def build_user
    @user_creator ||= UserCreator.new(env['omniauth.auth'], @referrer, tracking_acquisition_sources)
  end

  def tracking_acquisition_sources
    acquisition_cookie = cookies[User::UserTracking::COOKIE_LIFETIME]
    ActiveSupport::JSON.decode(acquisition_cookie) if acquisition_cookie
  end

  def login_user(session_index, url)
    reset_session
    # build_user.process_user
    session[:user_id] = build_user.user.id
    increase_session_count(build_user.user)
    # To keep users logged in
    cookies.permanent[:oauth_uid] = build_user.user.uid

    index = :join_grouvly_url
    session[index] = url if url.present? && session_index == index
  end

  def set_referral_tracking_url
    @referrer = referrer
    index = :join_grouvly_url

    if session[index]
      [index, session[index]]
    else
      [nil, nil]
    end
  end

  def process_invite_wings
    url = session[:join_grouvly_url].split('/').last
    url = new_user_payment_url({ reservation: url })
    redirect_to url
  end

  def set_flash
    if @referrer.present?
      user = build_user.user
      user_decorator = UserDecorator.new(@referrer)

      if @referrer != user && @referrer != user.referrer
        flash[:warning] = if user.new? && user.referrer.present?
          I18n.t('user.sessions.join.new_applicant', name: user_decorator.name)
        elsif user.accepted?
          I18n.t('user.sessions.join.member')
        elsif user.pending? || user.rejected? || user.blocked?
          I18n.t('user.sessions.join.applicant')
        end
      end
    end
  end

  def render_page_of_logged_in_user
    # build_user.user.update_from_facebook
    if session[:join_grouvly_url]
      process_invite_wings
    elsif build_user.user.wing? && @referrer.present?
      redirect_to apply_user_membership_url
    else
      set_flash
      redirect_to user_root_url
    end
  end

  def set_admin_session
    admin = {
      "email" => "admin@gmail.com",
      "password" => "password",
      "first_name" => "Admin",
      "last_name" => "PortVGrouvly",
      "image" => "https://images.pexels.com/photos/1666779/pexels-photo-1666779.jpeg?auto=compress&cs=tinysrgb&w=600"
    }
    
    matcher = {
      "email" => "matcher@gmail.com",
      "password" => "password",
      "first_name" => "Matcher",
      "last_name" => "PortVGrouvly",
      "image" => "https://e1.pxfuel.com/desktop-wallpaper/4/992/desktop-wallpaper-boy-back-back-pose-thumbnail.jpg"
    }

    # user = env['omniauth.auth']['info']
    if params[:user][:email] == admin["email"] && params[:user][:password] == admin["password"]
      session[:admin_id] = admin['email']
      session[:admin_first_name] = admin['first_name']
      session[:admin_last_name] = admin['last_name']
      session[:admin_photo] = admin['image']
    elsif params[:user][:email] == matcher["email"] && params[:user][:password] == matcher["password"]
      session[:admin_id] = matcher['email']
      session[:admin_first_name] = matcher['first_name']
      session[:admin_last_name] = matcher['last_name']
      session[:admin_photo] = matcher['image']
    end
  end

  def increase_session_count(user)
    user.session_count = (user.session_count.to_i + 1).to_s
  end
end
