class UserInfo < ApplicationRecord

  serialize :neighborhoods, Array
  serialize :meet_new_people_ages, Array
  serialize :typical_weekends, Array

  belongs_to :user

  validates :email_address, :current_work, :current_employer, :studied_at, :height, :native_place, presence: true

    validates :neighborhoods, presence: true, if: :user_location?

  validates :gender_to_match, inclusion: { in: APP_CONFIG['genders'] }
  validates :religion, inclusion: { in: APP_CONFIG['available_religions'] }
  validates :ethnicity, inclusion: { in: APP_CONFIG['available_ethnicities'] }
  validates :hang_out_with, inclusion: { in: APP_CONFIG['available_hang_outs'] }
  validates_format_of :phone, with: /\A(\d{8})\z/

  delegate :suggest_matching_gender, :suggest_location, to: :user_info_suggester
  delegate :set_error_messages, :set_default_values, :set_work, :set_education, :set_gender, :set_birthday,
    :set_other_details, :update_images, :update_from_facebook, to: :user_info_setter

  has_paper_trail

  def user_location?
    self.location == "Hong Kong" ? true : false
  end

  def user_info_suggester
    @user_info_suggester ||= UserInfoSuggester.new(self)
  end

  def user_info_setter
    @user_info_setter ||= UserInfoSetter.new(self)
  end

  def birthday
    if self.attributes["birthday"].is_a?(String)
      DateTime.parse(self.attributes["birthday"])
    else
      self.attributes["birthday"]
    end
  end
end
