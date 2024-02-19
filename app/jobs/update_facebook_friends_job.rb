class UpdateFacebookFriendsJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    begin
      graph = Koala::Facebook::API.new(user.oauth_token)
      me = graph.get_object('me')
      friends = graph.get_connections(me['id'], 'friends')

      friends.each do |friend|
        friendable = User.find_by_uid(friend['id'])

        if friendable.accepted?
          friendship = Friendship.where('(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)', user.id, friendable.id, friendable.id, user.id)
          Friendship.create!({ user_id: user.id, friend_id: friendable.id }) unless friendship.any?
        end
      end
    rescue
    end
  end
end
