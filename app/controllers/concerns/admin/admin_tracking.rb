module Admin::AdminTracking
  include Grouvly::SegmentTracking

  EVENT_APPLICANT_ACCEPTED = 'Accepted for Membership'
  EVENT_APPLICANT_REJECTED = 'Rejected for Membership'
end