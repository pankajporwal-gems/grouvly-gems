module User::Memberships
  extend ActiveSupport::Concern

  private

  def membership_params
    unless params[:continue]
      params[:user_info][:meet_new_people_ages] ||= []
      params[:user_info][:neighborhoods] ||= []
      params[:user_info][:typical_weekends] ||= []
    end
    params.require(:user_info).permit(:email_address, :gender_to_match, :location, :phone, :current_work,
      :studied_at, :religion, :ethnicity, :height, :current_employer, :gender, :birthday, :native_place, :hang_out_with, meet_new_people_ages:[], neighborhoods:[], typical_weekends:[])
  end

  def membership
    @membership ||= if current_user.user_info.present?
      current_user.user_info.assign_attributes(membership_params) if params[:user_info]
      current_user.user_info
    elsif params[:user_info]
      current_user.build_user_info(membership_params)
    else
      current_user.build_user_info
    end
  end

  def continue_with_step_two
    if membership.errors.blank?
      # membership.set_gender(me)
      # membership.set_birthday(me)
      # membership.set_work(me)
      # membership.set_education(me)
      @step_two_membership_presenter = StepTwoMembershipPresenter.new(membership)
      render 'step_two'
    else
      @new_membership_presenter = NewMembershipPresenter.new(membership)
      render 'new'
    end
  end

  def set_user_as_wing
    current_user.wing!
    url = session.delete(:join_grouvly_url).split('/').last
    url = new_user_payment_url({ reservation: url })
    redirect_to url
  end

  def set_user_as_pending
    current_user.pend!
    redirect_to finish_user_membership_url
  end

  def finish_submitting_membership
    membership.set_other_details(nil, nil, params[:user_info])  #for portfolio project
    # membership.set_other_details(me, graph, params[:user_info])
    membership.update_images
    if session[:join_grouvly_url]
      membership.save!(validate: false)
      set_user_as_wing
    else
      membership.save!
      set_user_as_pending
    end
  end

  def get_parameters_for_update
    parameters = membership_params
    parse_birthday(parameters)
    # if membership_params[:neighborhood] == t('terms.others')
    #   parameters[:neighborhood] = membership_params[:other_neighborhood]
    # end
    # if membership_params[:native_place] == t('terms.others')
    #   parameters[:native_place] = membership_params[:other_native_place]
    # end
    country = Carmen::Country.coded(parameters[:native_place])
    if country.present?
      parameters[:origin] = parameters[:location] == country.name ? APP_CONFIG['available_origins']['local'] : APP_CONFIG['available_origins']['expat']
    else
      parameters[:origin] = APP_CONFIG['available_origins']['expat']
    end
    parameters
  end

  def parse_birthday(parameters)
    birthday_hash = {
      1 => parameters.delete(:"birthday(1i)"),
      2 => parameters.delete(:"birthday(2i)"),
      3 => parameters.delete(:"birthday(3i)")
    }
    parameters[:birthday] = Date.new(birthday_hash[1].to_i, birthday_hash[2].to_i, birthday_hash[3].to_i)
    parameters
  end

  def prepare_edit_presenter
    @presenter = EditMembershipPresenter.new(membership)
    #@presenter.set_neighborhood
    current_user.reload
  end
end
