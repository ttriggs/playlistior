module FollowHelper
  def followed?(playlist)
    joined = Follow.find_by(user_id: current_user.id, playlist_id: playlist.id)
    (!playlist.owner?(current_user) && !joined) ? false : true
  end

  def all_playlists_following
    follows = Follow.where(user_id: current_user.id)
    follows.each_with_object([]) do |follow, playlists|
      if Playlist.exists?(follow.playlist_id)
        playlists << Playlist.find(follow.playlist_id)
      end
    end
  end

  def number_of_followers(playlist)
    Follow.where(playlist_id: playlist.id).count
  end
end
