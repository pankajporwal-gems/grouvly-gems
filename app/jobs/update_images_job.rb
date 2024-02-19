class UpdateImagesJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    @user = User.find(user_id)

    begin
      photos = build_photos
      @user.user_info.update_attribute(:photos, photos) if photos.present?
    rescue
      #@user.deauthorized!
    end
  end

  private

  def build_photos
    graph = Koala::Facebook::API.new(@user.oauth_token)
    albums = []

    graph.get_connections('me', 'albums', fields: 'type, photos.fields(source)').each do |album|
      photos = album['photos']

      if ['profile', 'wall'].include?(album['type']) && photos && photos['data']
        photos['data'].each { |photo| albums << photo['source'] }
      end
    end

    albums
  end
end
