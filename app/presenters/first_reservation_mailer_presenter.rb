class FirstReservationMailerPresenter
  delegate :first_date, :second_date, :third_date, to: :reservation_date_decorator
  delegate :gender_to_match, to: :user_info_decorator
  delegate :name, to: :user_decorator

  attr_accessor :deadline

  def initialize(user)
    @user ||= user
  end

  def user_info
    @user_info ||= @user.user_info
  end

  def user_decorator
    @user_decorator ||= UserDecorator.new(@user)
  end

  def user_info_decorator
    @user_info_decorator ||= UserInfoDecorator.new(user_info)
  end

  def reservation_date_decorator
    @reservation_date_decorator ||= ReservationDateDecorator.new(@user)
  end

  def user_first_name
    @user.first_name
  end

  def location
    @user.location
  end

  def is_male?
    @user.gender == 'male'
  end

  def referral_reward
    APP_CONFIG['referral_reward'][location]
  end

  def referral_currency
    APP_CONFIG['referral_currency'][location]
  end

  def referral_program_enabled?
    APP_CONFIG['referral_program_start_date'][location].present? &&
      APP_CONFIG['referral_program_start_date'][location] <= Chronic.parse('now')
  end

  def style
    css = "background-color: #16aace; color: white; font-size: 13px; padding: 7px 0; text-decoration: none;"
    css += " width: 300px; display: block; text-align: center; border-radius: 4px;"
  end
end
