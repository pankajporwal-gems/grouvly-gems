class UpdateFacebookJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    user_info = user.user_info

    begin
      graph = Koala::Facebook::API.new(user.oauth_token)
      me = graph.get_object('me')
      user_info.last_facebook_update = Time.now
      user_info.small_profile_picture = graph.get_picture(me['id'], { type: 'small' })
      user_info.normal_profile_picture = graph.get_picture(me['id'], { type: 'normal' })
      user_info.large_profile_picture = graph.get_picture(me['id'], { type: 'large' })
      user_info.work_history = me['work']
      user_info.education_history = me['education']
      user_info.likes = graph.get_connections(me['id'], 'likes')
      user_info.hometown = me['hometown']['name'] if me['hometown']
      user_info.save(validate: false)
    rescue
    end
  end
end
