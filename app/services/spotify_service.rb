class SpotifyService
  attr_reader :connection

  def initialize(token = nil)
    header_key = "Bearer #{token}"
    @connection = Faraday.new(url: "https://api.spotify.com")
    @connection.headers = { 'Authorization' => header_key }
  end

  # def playlist_tracks(tracks)
  #   parse(connection.get(tracks))
  # end

  def create_playlist(user_id, playlist_name)
    body = { name: playlist_name, public: false }.to_json
    response = connection.post("/v1/users/#{user_id}/playlists", body) do |request|
      request.headers.merge!('Content-Type' => 'application/json')
    end
    SpotifyResponse.new(response).return
  end

  def add_tracks(playlist_url, track_ids)
    body = { "uris" => track_ids }.to_json
    response = connection.post(playlist_url, body) do |request|
      request.headers.merge!('Content-Type' => 'application/json')
    end
    SpotifyResponse.new(response).return
  end

  #spotify
  def self.unfollow_playlist(playlist, user)
    token       = user.session_token
    owner_id    = user.spotify_id
    playlist_id = playlist.spotify_id
    url = playlist_follow_url(owner_id, playlist_id)
    params = { headers: { "Authorization" => "Bearer #{token}" } }
    HTTParty.delete(url, params)
  end

 #spotify
  def self.playlist_follow_url(owner_id, playlist_id)
    "https://api.spotify.com/v1/users/#{owner_id}/playlists/#{playlist_id}/followers"
  end

  class SpotifyResponse
    def initialize(response)
      @response = response
    end

    def failed?
      !success? || @response == false
    end

    def success?
      @response.status.between?(200, 202)
    end

    def return
      failed? ? error : parse(@response)
    end

    def error
      { errors: "Sorry, couldn't create a playlist for this artist." }
    end

    def parse(response)
      JSON.parse(response.body)
    end
  end
end
