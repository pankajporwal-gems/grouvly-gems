class UpdateUserProfileWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    User.find_each do |user|
      Rails.logger.info "UpdateUserProfileWorker processing for user_id: #{user.id}"

      user_info = user.user_info
      if user_info.blank? || user.uid.blank?
        Rails.logger.error "Error :: UpdateUserProfileWorker user-id #{user.id}, user.uid: #{user.uid}, user_info.blank?: #{user_info.blank?}"
        next
      end

      if can_update_fb_image_for?(user.id, user_info.normal_profile_picture)
        user_info.small_profile_picture = get_fb_profile_pic_for(user.uid, 'small')
        user_info.normal_profile_picture = get_fb_profile_pic_for(user.uid, 'normal')
        user_info.large_profile_picture = get_fb_profile_pic_for(user.uid, 'large')
        user_info.save(validate: false)
        UserCache.set_fb_image_last_updated(user.id, DateTime.now)
      end
    end
  end

  private

  def can_update_fb_image_for? user_id, fb_profile_picture
    valid_fb_pic = valid_fb_profile_pic?(fb_profile_picture)

    if valid_fb_pic
      UserCache.can_update_fb_image_for?(user_id)
    else
      true
    end
  end

  def valid_fb_profile_pic? fb_profile_picture
    res = if fb_profile_picture.present?
      Net::HTTP.get_response(URI(fb_profile_picture)) rescue nil
    end

    res.present? && res.code == "200" && res.msg == "OK"
  end
  def get_fb_profile_pic_for fb_uid, type
    res = Net::HTTP.get_response(URI("https://graph.facebook.com/#{fb_uid}/picture?type=#{type}"))
    res['location']
  end
end