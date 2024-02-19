class EditMembershipPresenter
  attr_reader :membership

  delegate :genders, :available_locations, to: :new_membership_presenter
  delegate :work_history, :education_history, :interests, to: :user_decorator
  delegate :available_religions, :available_religion_importance, :available_ethnicities,
    :available_ethnicity_importance, :available_neighborhoods, :available_ages, :available_hang_outs, :available_weekends, :native_available_locations, :available_hights, to: :step_two_membership_presenter

  def initialize(membership)
    @membership ||= membership
  end

  # def set_neighborhood
  #   unless available_neighborhoods.include?(@membership.neighborhood)
  #     @membership.other_neighborhood = @membership.neighborhood
  #     @membership.neighborhood = I18n.t('terms.others')
  #   end
  # end

  private

  def new_membership_presenter
    @new_membership_presenter ||= NewMembershipPresenter.new(@membership)
  end

  def step_two_membership_presenter
    @step_two_membership_presenter ||= StepTwoMembershipPresenter.new(@membership)
  end

  def user_decorator
    @user_decorator ||= UserDecorator.new(@membership.user)
  end
end
