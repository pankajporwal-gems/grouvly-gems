class UserScope
  GENDERS = APP_CONFIG['genders']
  SEXUAL_ORIENTATION = APP_CONFIG['sexual_orientation']

  def self.filter_members(options = {})
    options.delete_if{ |k, v| v.empty? }

    query = User.in_state(:accepted).joins(:user_info)
    query = query.where(user_infos: { location: options[:location] }) if options[:location]
    query = query.where(user_infos: { ethnicity: options[:ethnicity] }) if options[:ethnicity]
    query = query.where(user_infos: { hang_out_with: options[:hang_out_with] })  if options[:hang_out_with]
    query = query.where(user_infos: { origin: options[:origin] })  if options[:origin]


    # Gender / Sexual orientation
    if options[:gender]
      case options[:gender]
        when GENDERS['male']
          query = query.where(user_infos: { gender: 'male', gender_to_match: 'female' })
        when GENDERS['female']
          query = query.where(user_infos: { gender: 'female', gender_to_match: 'male' })
        when SEXUAL_ORIENTATION['gay']
          query = query.where(user_infos: { gender: 'male', gender_to_match: 'male' })
        when SEXUAL_ORIENTATION['lesbian']
          query = query.where(user_infos: { gender: 'female', gender_to_match: 'female' })
      end
    end

    # Age
    query = query.where("date_part('year', age(user_infos.birthday)) BETWEEN ? AND ?", options[:age_min], options[:age_max]) if options[:age_min] && options[:age_max]
    query = query.where("date_part('year', age(user_infos.birthday)) >= ?", options[:age_min]) if options[:age_min] && !options[:age_max]
    query = query.where("date_part('year', age(user_infos.birthday)) <= ?", options[:age_max]) if options[:age_max] && !options[:age_min]

    # Height
    query = query.where("user_infos.height BETWEEN ? AND ?", options[:height_min], options[:height_max]) if options[:height_min] && options[:height_max]
    query = query.where("user_infos.height >= ?", options[:height_min]) if options[:height_min] && !options[:height_max]
    query = query.where("user_infos.height <= ?", options[:height_max]) if options[:height_max] && !options[:height_min]

    # Text search
    if options[:name]
      name = options[:name].split
      query = query.where("LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ?", "%#{name.first.strip.downcase}%", "%#{name.last.strip.downcase}%")
    end
    #Array fields
    query = query.search_records(options[:typical_weekends], 'typical_weekends')  if options[:typical_weekends].present?
    query = query.search_records(options[:neighborhoods], 'neighborhoods') if options[:neighborhoods].present?
    query = query.search_records(options[:meet_new_people_ages], 'meet_new_people_ages')  if options[:meet_new_people_ages].present?

    query = query.order("transition1.created_at")
  end
end
