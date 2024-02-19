class SearchMemberPresenter
  def initialize
  end

  def available_locations
    APP_CONFIG['available_locations']
  end

  def genders
    APP_CONFIG['genders']
      .merge(APP_CONFIG['sexual_orientation'].except('straight'))
  end

  def religions
    APP_CONFIG['available_religions']
  end

  def origins
    APP_CONFIG['available_origins'].except('local_international', 'mainlander')
  end

  def hang_outs
    APP_CONFIG['available_hang_outs']
  end

   def available_neighborhoods
    APP_CONFIG['available_neighborhoods']
  end


  def typical_weekends
    APP_CONFIG['available_weekends']
  end

  def available_hights
    APP_CONFIG['user_heights']
  end

  def ages
    APP_CONFIG['available_ages']
  end

  def ethnicities
    APP_CONFIG['available_ethnicities']
  end

  def last_invitation
    [
      [I18n.t('admin.members.search.filters_form.last_invitation_never'), 0],
      [I18n.t('admin.members.search.filters_form.last_invitation_one_week'), 1],
      [I18n.t('admin.members.search.filters_form.last_invitation_two_weeks'), 2],
      [I18n.t('admin.members.search.filters_form.last_invitation_three_weeks'), 3],
      [I18n.t('admin.members.search.filters_form.last_invitation_four_weeks'), 4]
    ]
  end
end
