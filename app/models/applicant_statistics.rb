class ApplicantStatistics
  def self.get_all_stats
    @applicants_summary = []
    @straight_guys = 0
    @straight_girls = 0
    @gay_guys = 0
    @lesbians = 0

    APP_CONFIG['available_locations'].each do |location|
      query = User.applicants_by_location(location)

      straight_guys = query.where(user_infos: { gender: 'male', gender_to_match: 'female' }).count
      straight_girls = query.where(user_infos: { gender: 'female', gender_to_match: 'male' }).count
      gay_guys = query.where(user_infos: { gender: 'male', gender_to_match: 'male' }).count
      lesbians = query.where(user_infos: { gender: 'female', gender_to_match: 'female' }).count

      @straight_guys += straight_guys
      @straight_girls += straight_girls
      @gay_guys += gay_guys
      @lesbians += lesbians
      @applicants_summary << { location: location, straight_guys: straight_guys,
        straight_girls: straight_girls, gay_guys: gay_guys, lesbians: lesbians }
    end

    [@straight_guys, @straight_girls, @gay_guys, @lesbians, @applicants_summary]
  end

  def self.get_applicants(options)
    @applicants = User.applicants_by_location(options[:location])
    gender = options[:gender]

    if gender
      if gender == 'straight_guys'
        @applicants = @applicants.where(user_infos: { gender: 'male', gender_to_match: 'female' })
      elsif gender == 'straight_girls'
        @applicants = @applicants.where(user_infos: { gender: 'female', gender_to_match: 'male' })
      elsif gender == 'gay_guys'
        @applicants = @applicants.where(user_infos: { gender: 'male', gender_to_match: 'male' })
      elsif gender == 'lesbians'
        @applicants = @applicants.where(user_infos: { gender: 'female', gender_to_match: 'female' })
      end
    end

    @applicants
  end
end
