class UserInfoDecorator
  attr_reader :user_info

  def initialize(user_info)
    @user_info ||= user_info
  end

  def age
    birthday = @user_info.birthday

    if birthday
      now = Time.now.utc.to_date
      now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
    else
      nil
    end
  end

  def gender_to_match
    @user_info.gender_to_match == 'female' ? I18n.t('terms.girls') : I18n.t('terms.guys')
  end

  def phone
    @phone ||= case @user_info.location
    when 'Hong Kong'
      "+852 #{@user_info.phone}"
    when 'Singapore'
      "+65 #{@user_info.phone}"
    end
  end

  def work_history
    str = @user_info.try(:current_employer) ? @user_info.current_employer : ''
    str = "#{str} (#{@user_info.current_work})"
    work_history = @user_info.work_history
    str_arr = []

    if work_history
      str = str + ' / '

      work_history.each_with_index do |work, index|
        temp = work['employer']['name']
        temp = "#{temp} (#{work['position']['name']})" if work['position']
        str_arr << temp
      end

      str = str + str_arr.join(' / ')
    end
    str = I18n.t('terms.none') if str.nil? || str.strip! == ''
    str
  end

  def education_history
    str = @user_info.studied_at
    education_history = @user_info.education_history
    str_arr = []

    if education_history
      str = str + ' / '

      education_history.each_with_index do |education, index|
        temp = education['school']['name']
        temp = "#{temp} (#{education['concentration'][0]['name']})" if education['concentration']
        temp = "#{temp} (#{education['type']})" if education['type']
        str_arr << temp
      end

      str = str + str_arr.join(' / ')
    end
    str = I18n.t('terms.none') if str.nil? || str.strip! == ''
    str
  end

  def religion
    @user_info.religion
  end

  def ethnicity
    @user_info.ethnicity
  end

  def meet_at_location
    str = @user_info.neighborhoods
    [str].join(", ")
  end

  def interested_people_age
    str = @user_info.meet_new_people_ages
    [str].join(", ")
  end

  def hang_out_with
    @user_info.hang_out_with
  end

  def typical_weekend
    str = @user_info.typical_weekends
    [str].join(", ")
  end

  def interests
    if @user_info.likes.present?
      likes_array = []
      @user_info.likes.each { |like| likes_array << like['name'] }
      likes_array.join(' / ')
    else
      I18n.t('terms.none')
    end
  end

  def tags
    "#{ @user_info.work_category }, #{ @user_info.origin }, #{ @user_info.lifestyle }"
  end
end
