require 'action_controller/metal/helpers'

module User::UserTracking
  extend ActiveSupport::Concern
  include Grouvly::SegmentTracking

  EVENT_LOGGED_IN = 'Logged In'
  EVENT_LOGGED_OUT = 'Logged Out'
  EVENT_SIGNED_UP = 'Signed up with Facebook'
  EVENT_REGISTERED = 'Registered'
  EVENT_PAYMENT_COMPLETED = 'Booked a Grouvly'

  PAGE_HOME = 'Home'
  PAGE_MEMBERSHIP_NEW_STEP_1 = 'Form 1'
  PAGE_MEMBERSHIP_NEW_STEP_2 = 'Form 2'
  PAGE_MEMBERSHIP_NEW_INVITE = 'Invite friends'
  PAGE_MEMBERSHIP_CONFIRMATION = 'Confirmation of Registration'
  PAGE_MEMBERSHIP_EDIT_PROFILE = 'Edit Profile'
  PAGE_RESERVATION_PICK_DATE = 'Pick a date'
  PAGE_RESERVATION_PAYMENT = 'Pay for your date'
  PAGE_RESERVATION_NOTIFY = 'Notify Wingfriends'
  PAGE_RESERVATION_CONFIRMATION = 'Confirmation of Booking'
  PAGE_WING_INVITATION = 'Wingfriend Invitation'
  PAGE_FAQ = 'FAQ'
  PAGE_HOW_IT_WORKS = 'How it Works'
  PAGE_CONTACT_US = 'Contact us'
  PAGE_TOS = 'Terms of Service'
  PAGE_PRIVACY = 'Privacy Policy'
  PAGE_PRESS = 'Press'
  PAGE_ABOUT_US = 'About us'
  PAGE_VENUES = 'Bars and Venues'
  PAGE_FACEBOOK_FAILURE = 'Declined Facebook Landing'

  COOKIE_LIFETIME = '_grouvly_track'
  COOKIE_SESSION = '_grouvly_session_track'

  included do
    before_action :set_identifier
    before_action :set_traits
    before_action :set_cookies
  end

  # Segment JS
  def set_identifier
    if current_user
      gon.push({
        user_identifier: user_identifier
      })
    end
  end

  # Segment JS
  def set_traits
    if current_user && current_user.user_info.present?
      gon.push(user_traits)
    end
  end

  # Segment JS
  def track_page(name)
    # gon.push({pageName: name})
  end

  # Segment
  def track_event(name, options = {}, context = {})
    if current_user
      options = user_traits.merge(options) if current_user.user_info.present?

      segment_client.track(user_id: user_identifier, event: name, properties: options, context: context)
    end
  end

  def set_cookies
    referrer_parser = RefererParser::Parser.new
    referrer = referrer_parser.parse(request.referrer) if request.referrer

    tracking_values = {}
    tracking_values[:source] = params[:utm_source] || ( referrer[:source].downcase if referrer && !referrer[:source].blank? )
    tracking_values[:medium] = params[:utm_medium] || ( referrer[:medium] if referrer )
    tracking_values[:campaign] = params[:utm_campaign]
    tracking_values[:content] = params[:utm_content]
    tracking_cookie = { value: ActiveSupport::JSON.encode( tracking_values ), domain: request.host.delete('www'), path: '/' }

    unless cookies[COOKIE_SESSION].present?
      cookies[COOKIE_SESSION] = tracking_cookie
    end

    unless cookies[COOKIE_LIFETIME].present?
      cookies[COOKIE_LIFETIME] = tracking_cookie.merge({ expires: 1.year.from_now })
    end
  end

  def set_utm_properties
    session_cookie = cookies[User::UserTracking::COOKIE_SESSION]
    session_cookie_data = ActiveSupport::JSON.decode(session_cookie) if session_cookie

    properties = {
      utmSource: (session_cookie_data['source'] if session_cookie_data['source'].present?),
      utmChannel: (session_cookie_data['medium'] if session_cookie_data['medium'].present?),
      utmCampaign: (session_cookie_data['campaign'] if session_cookie_data['campaign'].present?),
      utmContent: (session_cookie_data['content'] if session_cookie_data['content'].present?)
    }
  end

  private

  def user_identifier
    current_user.slug
  end

  def user_traits
    user = UserDecorator.new(current_user)
    user_reservation = UserReservationScope.new(current_user)
    user_notes = UserNotesDecorator.new(current_user.user_notes)

    traits = {
      name: user.name, # Required by Zendesk
      firstName: current_user.first_name,
      lastName: current_user.last_name,
      email: current_user.email_address,
      age: user.age,
      gender: user.gender,
      height: current_user.height,
      ethnicity: current_user.ethnicity,
      education: current_user.studied_at,
      title: current_user.current_work,
      company: current_user.current_employer,
      phone: current_user.phone,
      city: current_user.location,
      facebookID: current_user.uid,
      tags: user.tags,
      signUpDate: current_user.created_at,
      notes: user_notes.to_list, # Used by Zendesk

      grouvlerType: current_user.membership_type,
      acceptanceDate: (current_user.changed_state_on?(:accepted) if current_user.accepted?),
      totalGrouvlyBooked: user_reservation.total_reservations,
      totalGrouvlyCompleted: user_reservation.total_reservations_completed,
      nextGrouvlyDate: (user_reservation.latest_reservation.schedule if user_reservation.latest_reservation.present?),
      lastGrouvlyDate: (user_reservation.last_reservation.schedule if user_reservation.last_reservation.present?),

      referred: user.referred,
      membership: current_user.current_state,
      sessionCount: current_user.session_count,

      acquisitionSource: current_user.acquisition_source,
      acquisitionChannel: current_user.acquisition_channel
    }
  end
end
