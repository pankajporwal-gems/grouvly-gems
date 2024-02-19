class StepTwoMembershipPresenter
  attr_reader :membership

  def initialize(membership)
    @membership ||= membership
  end

  def user_info_decorator
    @user_info_decorator ||= UserInfoDecorator.new(@membership)
  end

  def available_religions
    APP_CONFIG['available_religions']
  end

  def available_religion_importance
    APP_CONFIG['available_religion_importance']
  end

  def available_ethnicities
    APP_CONFIG['available_ethnicities']
  end

  def available_ethnicity_importance
    APP_CONFIG['available_ethnicity_importance']
  end

  def available_neighborhoods
    APP_CONFIG['available_neighborhoods']
  end

  def available_ages
    APP_CONFIG['available_ages']
  end

  def available_hang_outs
    APP_CONFIG['available_hang_outs']
  end

  def available_weekends
    APP_CONFIG['available_weekends']
  end

  def available_hights
    APP_CONFIG['user_heights']
  end

  def native_available_locations
    APP_CONFIG['available_locations'] | [I18n.t('terms.others')]
  end
end
