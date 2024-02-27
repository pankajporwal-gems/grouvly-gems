class UserDecorator
  attr_reader :user

  delegate :age, :gender_to_match, :phone, :work_history, :education_history, :interests, :tags, :interested_people_age, :hang_out_with, :typical_weekend, :religion, :ethnicity, :meet_at_location, to: :user_info_decorator

  def initialize(user)
    @user ||= user
  end

  def user_info_decorator
    @user_info_decorator ||= UserInfoDecorator.new(@user.user_info)
  end

  def name
    "#{@user.first_name} #{@user.last_name}"
  end

  def location
    @user.location
  end

  def gender
    if @user.gender_to_match == 'female' && @user.gender == 'male'
      I18n.t('admin.terms.straight_male')
    elsif @user.gender_to_match == 'male' && @user.gender == 'female'
      I18n.t('admin.terms.straight_female')
    elsif @user.gender_to_match == 'male' && @user.gender == 'male'
      I18n.t('admin.terms.gay')
    else
      I18n.t('admin.terms.lesbian')
    end
  end

  def wing_type
    if @user.gender == 'male'
      I18n.t('user.reservations.wingmen')
    else
      I18n.t('user.reservations.wingwomen')
    end
  end

  def headline
    status = I18n.t('admin.members.joined')
    status = I18n.t('admin.members.rejected') if @user.rejected?
    parsed_metadat = JSON.parse(@user.user_transitions.last.metadata)
    date = Date.parse(parsed_metadat['occured_on']).strftime(' %B %d %Y')

    "#{I18n.t('admin.members.in')} #{@user.location} - #{status} #{date}"
  end

  def referred
    if @user.referrer
      true.humanize
    else
      false.humanize
    end
  end

  def total_credits
    user.total_credits.to_i
  end

  def available_credits
    user.available_credits.to_i
  end
end
