module PlaylistHelper
  def all_genres_in_use
    Playlist.all.each_with_object(genres = []) do |playlist|
      genres.concat(playlist.genres)
    end
    genres.uniq
  end

  def playlists_by_genre(genre)
    Playlist.all.each_with_object(playlists = []) do |playlist|
      if playlist.genres.include?(genre)
        playlists << playlist
      end
    end
    playlists.uniq
  end
end
