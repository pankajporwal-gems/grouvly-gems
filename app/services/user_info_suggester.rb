class UserInfoSuggester
  LOCATIONS = APP_CONFIG['available_locations']
  GENDERS = APP_CONFIG['genders']

  def initialize(user_info)
    @user_info ||= user_info
  end

  def suggest_matching_gender(gender)
    if gender == 'male'
      @user_info.gender_to_match = GENDERS['female']
    else
      @user_info.gender_to_match = GENDERS['male']
    end
  end

  def suggest_location(location)
    if location
      location = location['name']
      @user_info.location = location if LOCATIONS.include?(location)
    end
  end
end
