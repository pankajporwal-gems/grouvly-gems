class NewMembershipPresenter
  attr_reader :membership

  def initialize(membership)
    @membership ||= membership
  end

  def genders
    APP_CONFIG['genders']
  end

  def available_locations
    APP_CONFIG['available_locations']
  end
end
