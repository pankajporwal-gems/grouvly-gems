class User < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries
  extend FriendlyId

  before_destroy :delete_referrer

  has_one :user_info, dependent: :destroy
  has_many :user_notes, dependent: :destroy
  has_many :referrals, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :unmatched_reservation_histories, dependent: :destroy
  has_many :user_transitions, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :credits, dependent: :destroy
  has_many :vouchers, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  delegate :latest_reservation, :admin_latest_reservation, :last_reservation, :has_paid_reservation_on?, :total_reservation_amount, :valid_and_pending_reservations,
    :total_reservations, :total_matched_and_paid_reservations, :total_reservations_as_wing,
    :total_reservations_as_lead, :valid_reservations, :has_panding_reservation_on?, to: :user_reservation_scope
  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state, :history, to: :state_machine
  delegate :last_facebook_update, :small_profile_picture, :normal_profile_picture, :large_profile_picture,
    :birthday, :work_history, :work_category, :education_history, :likes, :email_address, :current_work, :studied_at, :meet_new_people_ages,
    :gender_to_match, :location, :gender, :origin, :ethnicity, :religion, :height, :neighborhoods, :phone, :native_place, :hang_out_with, :typical_weekends, :current_employer, :photos, :update_images,
    :update_from_facebook, :lifestyle, :linkedin_link, :hometown, to: :user_info
  delegate :new?, :pending?, :accepted?, :rejected?, :wing?, :blocked?, :deauthorized?, :new!, :pend!,
    :wing!, :accept!, :reject!, :deauthorized!, :changed_state_on?, to: :user_state
  delegate :age, to: :user_info_decorator
  delegate :name, to: :user_decorator
  delegate :total_credits, :available_credits, :credits_can_use, :used_credits, :has_credits?, to: :user_credit_scope
  delegate :referrer, :valid_referrals, :delete_referrer, to: :user_referral_scope
  delegate :total_revenue, to: :user_payment_scope
  delegate :has_redeemed_voucher?, :has_already_relunch_redeemed_voucher?, :vouchers_used, :total_vouchers, to: :user_voucher_scope

  accepts_nested_attributes_for :user_info

  friendly_id :slug_candidates, use: :slugged

  scope :users_accepted_yesterday_and_not_booked, -> {
    in_state(:accepted)
      .where('users.id NOT IN (SELECT user_id FROM reservations LEFT JOIN payments ON payments.reservation_id=reservations.id WHERE payments.status=? GROUP BY user_id)', 'success')
      .where("transition1.created_at BETWEEN ? and ?", Chronic.parse('yesterday at 2am'), Chronic.parse('today at 1:59am'))
      .order('id')
      .uniq
  }

  scope :applicants_by_location, -> (location) {
    in_state(:pending).joins(:user_info).where(user_infos: { location: location })
      .order('transition1.created_at')
  }

  scope :members_by_location, -> (location) {
    in_state(:accepted).joins(:user_info).where(user_infos: { location: location })
      .order('transition1.created_at')
  }

  scope :search_records, -> (params, type) { where(search_query(params, type)) }

  has_paper_trail

  def self.search_query(params, type)
    params.map { |param| "(#{type} LIKE '%#{param}%')" }.join('AND')
  end


  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      column_names = %w(first_name last_name email_address gender gender_to_match location phone, neighborhoods current_work current_employer studied_at religion ethnicity home_towm meet_new_people_ages hang_out_with typical_weekends height likes).map!(&:humanize)
      csv << column_names
      all.joins(:user_info).find_each do |member|
        csv << [member.first_name, member.last_name, member.email_address, member.gender, member.gender_to_match, member.location, member.phone, [member.neighborhoods].join(", "), member.current_work, member.current_employer, member.studied_at, member.religion, member.ethnicity, member.native_location, [member.meet_new_people_ages].join(", "), member.hang_out_with, [member.typical_weekends].join(", "), APP_CONFIG['user_heights'].key(member.height), member.intersts]
      end
    end
  end

  def intersts
    if likes.present?
      likes_array = []
      likes.each { |like| likes_array << like['name'] }
      likes_array.join(' / ')
    else
      'none'
    end
  end

  def self.find_by_oauth(uid)
    where(uid: uid).where('oauth_expires_at > ?', Chronic.parse('today')).first
  end

  def self.by_email_and_name(email, name)
    if email.present? && name.present?
      query = "user_infos.email_address = ? and lower(users.first_name) LIKE ? or lower(users.last_name) LIKE ?", email, "%#{name.first.downcase}%", "%#{name.last.downcase}%"
    elsif email.present?
      query = "user_infos.email_address = ?", email
    elsif name.present?
      query = "lower(users.first_name) LIKE ? or lower(users.last_name) LIKE ?", "%#{name.first.downcase}%", "%#{name.last.downcase}%"
    end
    in_state(:accepted).joins(:user_info).where(query)
  end

  def self.transition_class
    UserTransition
  end

  def self.initial_state
    StateMachines::User.initial_state
  end

  def active_card
    if valid_cards.present?
      valid_cards.sort_by(&:updated_at).last
    end
  end

  def valid_cards
    if cards.present?
      valid_cards = []
      cards.map{|card| valid_cards << card if Grouvly::BraintreeApi.find_payment_method(card)}
      valid_cards
    end
  end

  def native_location
    country = Carmen::Country.coded(self.native_place)
    country.present? ? country.name : self.native_place
  end

  def state_machine
    @state_machine ||= StateMachines::User.new(self, transition_class: UserTransition)
  end

  def user_state
    @user_state ||= UserState.new(self)
  end

  def user_reservation_scope
    @user_reservation_scope ||= UserReservationScope.new(self)
  end

  def user_info_setter
    @user_info_setter ||= UserInfoSetter.new(self)
  end

  def user_info_decorator
    @user_info_decorator ||= UserInfoDecorator.new(self.user_info)
  end

  def user_decorator
    @user_decorator ||= UserDecorator.new(self)
  end

  def user_credit_scope
    @user_credit_scope ||= UserCreditScope.new(self)
  end

  def user_referral_scope
    @user_referral_scope ||= UserReferralScope.new(self)
  end

  def user_payment_scope
    @user_payment_scope ||= UserPaymentScope.new(self)
  end

  def user_voucher_scope
    @user_voucher_scope ||= UserVoucherScope.new(self)
  end

  def slug_candidates
    [[:first_name, :last_name]]
  end

  def has_same_gender_as?(user)
    gender == user.gender
  end

  def is_first_time_payer?
    customer_id.blank?
  end

  def recently_signed_up?
    session_count == 1 && created_at + 3.seconds >= Chronic.parse('now')
  end

  def recently_completed_application?
    user_transitions.find_by_to_state('pending').created_at + 3.seconds >= Chronic.parse('now')
  end

  def recently_accepted?
    if self.accepted?
      user_transitions.find_by_to_state('accepted').created_at + 3.seconds >= Chronic.parse('now')
    end
  end

  def recently_rejected?
    if self.rejected?
      user_transitions.find_by_to_state('rejected').created_at + 3.seconds >= Chronic.parse('now')
    end
  end

  def all_friends
    all_friends = friends

    if all_friends.any? && inverse_friends.any?
      all_friends = all_friends + inverse_friends
    elsif inverse_friends.any?
      all_friends = inverse_friends
    end

    all_friends
  end
end
