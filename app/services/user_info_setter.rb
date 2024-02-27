class UserInfoSetter
  include ActiveModel::Model

  attr_reader :user_info

  def initialize(user_info)
    @user_info ||= user_info
  end

  def set_error_messages(params)
    param_keys = params.keys
    error_keys = @user_info.errors.messages.keys.map(&:to_s)

    error_keys.each do |error_key|
      @user_info.errors.messages.delete(error_key.to_sym) unless param_keys.include? error_key
    end
  end

  def set_default_values(me)
    @user_info.email_address ||= me['email']
    @user_info.hometown ||= me['hometown']['name'] if me['hometown']
    @user_info.suggest_matching_gender(me['gender'])
    @user_info.suggest_location(me['location'])
  end

  def set_gender(me)
    @user_info.gender = me['gender'] if @user_info.gender.blank?
  end

  def set_birthday(me)
    if @user_info.birthday.blank?
      birthday = Date.strptime(me['birthday'], '%m/%d/%Y')
      @user_info.birthday = birthday
    end
  end

  def set_work(me)
    if me['work']
      work = me['work'].select { |work| work['position'].present? }
      set_current_work(work )
      @user_info.work_history = me['work']
    end
  end

  def set_education(me)
    if me['education']
      school = me['education'].select { |school| school['type'] == 'College' }
      set_current_education(school)
      @user_info.education_history = me['education']
    end
  end

  def set_other_details(me, graph, params)
    @user_info.last_facebook_update = Time.now
    # @user_info.small_profile_picture = graph.get_picture(me['id'], { type: 'small' })
    # @user_info.normal_profile_picture = graph.get_picture(me['id'], { type: 'normal' })
    # @user_info.large_profile_picture = graph.get_picture(me['id'], { type: 'large' })
    # @user_info.likes = graph.get_connections(me['id'], 'likes')
    # set_neighborhood(params)
    #For portfolio project
    if params['birthday']
      birthday = eval(params['birthday'])
      @user_info.birthday = Date.new(birthday[1], birthday[2], birthday[3])
    else
      birthday_hash = {
      1 => params.delete(:"birthday(1i)"),
      2 => params.delete(:"birthday(2i)"),
      3 => params.delete(:"birthday(3i)")
    }
      @user_info.birthday = Date.new(birthday_hash[1].to_i, birthday_hash[2].to_i, birthday_hash[3].to_i)
    end
    set_native_place(params)
  end

  def update_images
    UpdateImagesJob.perform_now(user.id)
  end

  def update_from_facebook
    if last_facebook_update > 30.days.ago.to_f
      UpdateFacebookJob.perform_now(user.id)
      update_images
    end
  end

  private

  def user
    @user ||= @user_info.user
  end

  def set_current_work(work)
    if work && work.first
      if work.first['employer']
        employer = work.first['employer']['name']
        @user_info.current_employer = employer if employer
      end

      if work.first['position']
        position = work.first['position']['name']
        @user_info.current_work = position if position
      end
    end
  end

  def set_current_education(school)
    if school && school.first
      school_name = school.first['school']['name'] if school.first['school']
      @user_info.studied_at = school_name if school_name
    end
  end

  # def set_neighborhood(params)
  #   if @user_info.neighborhood == I18n.t('terms.others')
  #     @user_info.neighborhood = params['other_neighborhood']
  #   end
  # end

  def set_native_place(params)
    # if @user_info.native_place == I18n.t('terms.others')
    #   @user_info.native_place = params['other_native_place']
    # end
    country = Carmen::Country.coded(@user_info.native_place)
    if country.present?
      @user_info.origin = @user_info.location == country.name ? APP_CONFIG['available_origins']['local'] : APP_CONFIG['available_origins']['expat']
     else
      @user_info.origin = APP_CONFIG['available_origins']['expat']
    end
  end

  def last_facebook_update
    Time.now.to_f - @user_info.last_facebook_update.to_f
  end
end
