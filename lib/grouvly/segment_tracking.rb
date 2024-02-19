require 'segment/analytics'

module Grouvly
  module SegmentTracking
    extend self

    EVENT_GROUVLY_COMPLETED = 'Went on a Grouvly'

    def track_event(user, name, options = {}, context = {})
      user_decorator = UserDecorator.new(user)
      options = {
        user_age: user_decorator.age,
        user_gender: user_decorator.gender,
        religion: user.user_info.religion,
        ethnicity: user.user_info.ethnicity,
        education: user_decorator.education_history,
        interested_in: user_decorator.interests
      }.merge(options)

      segment_client.track(user_id: user.slug, event: name, properties: options, context: context)
    end

    # Push all events out of the queue
    # see doc: https://segment.com/docs/libraries/ruby/#flush
    # see issue: https://github.com/segmentio/analytics-ruby/issues/77
    def flush
      segment_client.flush
    end

    private

    def segment_client
      Segment::Analytics.new({
        write_key: ENV['SEGMENT_TRACKING_KEY'],
        batch_size: 1
      })
    end
  end
end