module PlaylistHelper
  def all_genres_in_use
    Genre.joins(:playlists).order('group_id asc').uniq
  end

  def playlists_by_genre(genre)
    Genre.find_by(name: genre).playlists
  end

  def get_their_playlists
    Playlist.where.not(user_id: current_user.id).
                   order(follows_cache: :desc).
                   take(30)
  end
end
