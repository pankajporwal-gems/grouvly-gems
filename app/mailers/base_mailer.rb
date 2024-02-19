class BaseMailer < ActionMailer::Base
  include ApplicationHelper

  def set_concierge_name
    @concierge_name = if @user.present?
      APP_CONFIG['concierge_name'][@user.location]
    else
      APP_CONFIG['default_concierge_name']
    end
  end

  def set_concierge_first_name
    @concierge_first_name = if @user.present?
      APP_CONFIG['concierge_first_name'][@user.location]
    else
      APP_CONFIG['default_concierge_first_name']
    end
  end

  def set_concierge_email
    @concierge_email = if @user.present?
      APP_CONFIG['concierge_email'][@user.location]
    else
      APP_CONFIG['default_concierge_email']
    end
  end

  def set_concierge_phone
    @concierge_phone = if @user.present?
      APP_CONFIG['concierge_phone'][@user.location]
    else
      APP_CONFIG['default_concierge_phone']
    end
  end

  def set_concierge_country
    @concierge_country = if @user.present?
      @user.location
    else
      APP_CONFIG['default_concierge_country']
    end
  end

  def set_concierge_details
    set_concierge_name
    set_concierge_first_name
    set_concierge_email
    set_concierge_phone
    set_concierge_country
  end
end
