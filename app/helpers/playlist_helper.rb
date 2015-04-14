module PlaylistHelper
  ARTIST_BUCKET = ["id:spotify-WW", :hotttnesss, :familiarity, :artist_location,
        :discovery, :discovery_rank, :familiarity, :genre,
        :hotttnesss, :hotttnesss_rank, :images, :songs]


  def add_tracks_to_playlist(playlist)
binding.pry
    params = { body: { "uris"=> "unfinished"}.to_json,
               headers: {"Authorization" => "Bearer #{session[:token]['number']}",
               "Content-Type" => "application/json"}
             }
    url = "#{current_user.spotify_link}/playlists/#{playlist["id"]/tracks}"
    HTTParty.post(url, params)
  end

end
