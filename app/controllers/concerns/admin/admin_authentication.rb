module Admin::AdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_filter :authenticate_admin!
  end

  def authenticate_admin!
    redirect_to root_url unless current_admin
  end
end
