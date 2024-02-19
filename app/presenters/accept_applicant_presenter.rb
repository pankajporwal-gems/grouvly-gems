class AcceptApplicantPresenter
  attr_reader :user

  def initialize(user)
    @user ||= user
  end

  def available_membership_types
    APP_CONFIG['available_membership_types']
  end

  def default_membership_type
    APP_CONFIG['default_membership_type']
  end

  def available_work_categories
    APP_CONFIG['available_work_categories']
  end

  def available_origins
    APP_CONFIG['available_origins']
  end

  def available_lifestyles
    APP_CONFIG['available_lifestyles']
  end
end
