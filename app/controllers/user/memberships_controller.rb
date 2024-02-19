class User::MembershipsController < User::UsersController
  include User::MembershipAuthorizations
  include User::Memberships
  include User::UserTracking

  def new
    @new_membership_presenter = NewMembershipPresenter.new(membership)
    track_event(EVENT_SIGNED_UP, set_utm_properties)
    track_page(PAGE_MEMBERSHIP_NEW_STEP_1)
  end

  def create
    membership.valid?
    membership.set_error_messages(params[:user_info])
    if params[:continue]
      track_page(PAGE_MEMBERSHIP_NEW_STEP_2)
      continue_with_step_two
    elsif membership.errors.messages.blank? || params[:skip]
      finish_submitting_membership
      track_registration_complete
    else
      @step_two_membership_presenter = StepTwoMembershipPresenter.new(membership)
      track_page(PAGE_MEMBERSHIP_NEW_STEP_2)
      render 'step_two'
    end
  end

  def edit
    prepare_edit_presenter
    track_page(PAGE_MEMBERSHIP_EDIT_PROFILE)
  end

  def update
    if (get_parameters_for_update[:location] != membership.location) && current_user.latest_reservation
      flash.now[:error] = t('user.memberships.errors.cannot_change_location')
    elsif membership.update(get_parameters_for_update)
      flash.now[:success] = t('user.memberships.edit.information_updated_successfully')
    end
    prepare_edit_presenter
    render 'edit'
  end

  def apply
    prepare_edit_presenter
    flash.now[:warning] = t('user.memberships.apply.review_your_information')
  end

  def submit_application
    if membership.update(get_parameters_for_update)
      set_user_as_pending
    else
      flash.now[:warning] = t('user.memberships.apply.review_your_information')
      prepare_edit_presenter
      render 'apply'
    end
  end

  def invite
    render not_found and return unless referral_program_enabled?

    @user_decorator = UserDecorator.new(current_user)
    @campaign_id = APP_CONFIG['referral_invite_campaign'][current_user.location]
    track_page(PAGE_MEMBERSHIP_NEW_INVITE)
  end

  def finish
    track_page(PAGE_MEMBERSHIP_CONFIRMATION)
  end

  private

  def track_registration_complete
    event_properties = {
      title: current_user.current_work,
      company: current_user.current_employer,
      education: current_user.studied_at,
      height: current_user.height
    }.merge(set_utm_properties)
    track_event(EVENT_REGISTERED, event_properties)
  end
end
