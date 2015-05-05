class TokenService

  def self.new_tokens(code)
    response = connection.post "/api/token" do |request|
      request.headers = auth_header
      request.body = { grant_type: "authorization_code",
                       code: code,
                       redirect_uri: redirect_uri }
    end
    parse(response)
  end

  def self.refresh_token
    response = connection.post "/api/token" do |request|
      request.headers = auth_header
      request.body = { grant_type: "refresh_token",
                       refresh_token: session[:token]["refresh"] }
    end
    parse(response)
  end

  private

  def self.auth_header
    { "Authorization" => "Basic #{encoded_id_and_secret}" }
  end

  def self.parse(response)
    JSON.parse(response.body)
  end

  def self.connection
    Faraday.new url: spotify_url
  end

  def self.spotify_url
    "https://accounts.spotify.com"
  end

  def self.encoded_id_and_secret
    Base64.strict_encode64("#{client_id}:#{client_secret}")
  end

  def self.spotify_auth_url
    client   = "client_id=#{client_id}"
    response = "response_type=code"
    redirect = "redirect_uri=#{redirect_uri}"
    my_scope = "scope=#{scope}"
    "#{spotify_url}/authorize?#{client}&#{response}&#{redirect}&#{my_scope}"
  end

  def self.client_id
    ENV["SPOTIFY_APP_ID"]
  end

  def self.client_secret
    ENV["SPOTIFY_SECRET"]
  end

  def self.scope
    CGI.escape("user-read-email user-read-private playlist-modify-private playlist-read-private")
  end

  def self.redirect_uri
    ENV['SPOTIFY_CALLBACK_URI']
  end
end
