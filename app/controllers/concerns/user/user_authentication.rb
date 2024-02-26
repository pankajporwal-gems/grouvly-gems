module User::UserAuthentication
  extend ActiveSupport::Concern

  included do
    # before_filter :authenticate_user, except: [:join, :confirm_venue_notification]
    before_filter :check_user_blocked, except: [:join, :confirmed, :dashboard, :confirm_venue_notification]
    before_filter :check_user_rejected, except: [:join, :confirmed, :dashboard, :confirm_venue_notification]
    before_filter :check_user_deauthorized, except: [:join, :confirmed, :dashboard, :confirm_venue_notification]
    before_filter :check_membership_info, except: [:join, :confirmed, :dashboard, :confirm_venue_notification]

    # prepend_before_filter :auto_facebook_login, except: [:join, :confirmed, :dashboard, :confirm_venue_notification]
  end

  def authenticate_user
    if current_user.blank?
      session[:return_to] ||= request.url
      flash[:success] = I18n.t('terms.you_need_to_login_html', { login_link: page_presenter.login_url })

      redirect_to root_url and return
    end
  end

  def auto_facebook_login
    if current_user.blank? && cookies['oauth_uid']
      user = User.find_by_oauth(cookies['oauth_uid'])
      if user
        oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], ENV['FACEBOOK_CALLBACK_URL'])
        redirect_to oauth.url_for_oauth_code({ permissions: APP_CONFIG['facebook_permissions'] }) and return
      else
        # Clear uid cookie if no matching user is found
        cookies.delete(:oauth_uid)
      end
    end
  end

  def check_user_blocked
    redirect_to root_url and return if current_user.blocked?
  end

  def check_user_rejected
    redirect_to finish_user_membership_url and return if current_user.rejected?
  end
  
  def check_user_deauthorized
    if current_user.deauthorized?
      history = current_user.history
      state = history[history.count - 2]
      params = { occured_on: Time.now }
      params['performed_by'] = state.metadata['performed_by'] if state.to_state == 'accepted'

      current_user.transition_to(state.to_state, params)
    end
  end

  def check_membership_info
    redirect_to new_user_membership_url and return if current_user.new?
  end

  def check_user_pending
    redirect_to finish_user_membership_url and return if current_user.pending?
  end
end
