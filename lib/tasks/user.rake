namespace :user do
  desc 'CRON job to update facebook info of users'
  task update_facebook_info: :environment do
    users = User.not_in_state(:new).joins(:user_info).where('user_infos.last_facebook_update <= ?', Chronic.parse('1 month from now at 12 AM'))

    users.each do |user|
      UpdateFacebookJob.perform_now(user.id)
      UpdateImagesJob.perform_now(user.id)
    end
  end

  desc 'CRON job to update facebook friends of users'
  task update_facebook_friends: :environment do
    users = User.in_state(:accepted).joins(:user_info).where('user_infos.last_facebook_update <= ?', Chronic.parse('1 month from now at 12 AM'))

    users.each do |user|
      UpdateFacebookFriendsJob.perform_now(user.id)
    end
  end

  desc 'CRON job to update facebook profile picture'
  task update_facebook_profile_image: :environment do
    UpdateUserProfileWorker.perform_async
  end


  desc 'CRON job to update user height and native place'
  task update_user_info: :environment do
    user_heights = APP_CONFIG['user_heights'].except("Less then 5'ft(Less then 152cm)","7'ft(213cm)","More then 7'ft(More then 213cm)").values
    all_user_heights = APP_CONFIG['user_heights'].values
    User.find_each do |user|
      user_info = user.user_info
      if user_info.present?
        user_info.native_place = "" unless user.native_location.present?
        if user_info.height.present?
          height = user_info.height
          unless all_user_heights.include? (height.to_s)
           user_info.height = if height.to_i < 152
                      "less-then-152cm"
                    elsif height.to_i == 213
                      "213cm"
                    elsif height.to_i > 213
                      "More then 213cm"
                    end
            user_heights.each do |user_height|
              user_info.height = user_height if user_height.gsub("cm", "").split("-").include?(height.to_s)
            end
          end
        end
        user_info.save(:validate => false)
      end
    end
  end
end
