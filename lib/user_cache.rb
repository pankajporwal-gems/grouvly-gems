#UserCache.set_fb_image_last_updated user_id, Time.now.to_i
#UserCache.can_update_fb_image_for? user_id
class UserCache
  class << self
    FB_IMAGE_LAST_UPDATED_KEY = 'fb-image-last-updated'
    RELAUNCH_EMAIL = 're'
    SEND_UNMATCHED_EMAIL = 'unmatched_re'
    NOT_SETTLED_PAYMENT = "not_settled_payment"


    def redis_user_id user_id
      "u:#{user_id}"
    end

    def redis_key user_id, key
      "#{redis_user_id(user_id)}:#{key}"
    end

    def redis_payment_id payment_id
      "p:#{payment_id}"
    end

    def redis_payment_key payment_id, key
      "#{redis_payment_id(payment_id)}:#{key}"
    end

    def redis_reservation_id reservation_id
      "r:#{reservation_id}"
    end

    def reservation_redis_key reservation_id, date,  key
      reservation = reservation_id + date
      "#{redis_reservation_id(reservation)}:#{key}"
    end


    def set_fb_image_last_updated user_id, time
      $redis_user_cache.set(redis_key(user_id, FB_IMAGE_LAST_UPDATED_KEY), time.to_i)
      $redis_user_cache.expire(redis_key(user_id, FB_IMAGE_LAST_UPDATED_KEY), (time + 1.month).to_i)
    end

    def get_fb_image_last_updated user_id
      $redis_user_cache.get(redis_key(user_id, FB_IMAGE_LAST_UPDATED_KEY))
    end

    def can_update_fb_image_for? user_id
      15.days.ago.to_i > get_fb_image_last_updated(user_id).to_i
    end

    def set_sent_relaunch_email user_id
      $redis_user_cache.set(redis_key(user_id, RELAUNCH_EMAIL), 'sent')
      $redis_user_cache.expire(redis_key(user_id, RELAUNCH_EMAIL), (2.month).to_i)
    end

    def set_enqued_relaunch_email user_id
      $redis_user_cache.set(redis_key(user_id, RELAUNCH_EMAIL), 'enqued')
      $redis_user_cache.expire(redis_key(user_id, RELAUNCH_EMAIL), (2.month).to_i)
    end

    def can_send_relaunch_email_for? user_id
      $redis_user_cache.get(redis_key(user_id, RELAUNCH_EMAIL)).blank?
    end

    def set_unmatched_email_send reservation_id, date
      $redis_user_cache.set(reservation_redis_key(reservation_id, date.to_i, SEND_UNMATCHED_EMAIL), "send_mail")
      $redis_user_cache.expire(reservation_redis_key(reservation_id, date.to_i, SEND_UNMATCHED_EMAIL), (date + 2.month).to_i)
    end

    def get_unmatched_email_send reservation_id, date
      $redis_user_cache.get(reservation_redis_key(reservation_id, date.to_i, SEND_UNMATCHED_EMAIL))
    end

    def set_not_settled_payment reservation_id, count
      $redis_user_cache.set(redis_payment_key(reservation_id, NOT_SETTLED_PAYMENT), count)
      $redis_user_cache.expire(redis_payment_key(reservation_id, NOT_SETTLED_PAYMENT), (2.month).to_i)
    end

    def get_not_settled_payment reservation_id
      $redis_user_cache.get(redis_payment_key(reservation_id, NOT_SETTLED_PAYMENT))
    end

  end
end