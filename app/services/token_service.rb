class TokenService

  def self.refresh_token
    response = connection.post "/api/token" do |request|
      request.headers = { "Authorization" => "Basic #{encoded_id_and_secret}" }
      request.body = { grant_type: "refresh_token",
                       refresh_token: session[:token]["refresh"] }
    end
    parse(response)
  end

  private

  def self.parse(response)
    JSON.parse(response.body)
  end

  def self.connection
    Faraday.new url: "https://accounts.spotify.com"
  end

  def self.encoded_id_and_secret
    Base64.strict_encode64("#{client_id}:#{client_secret}")
  end

  def self.client_id
    ENV["SPOTIFY_APP_ID"]
  end

  def self.client_secret
    ENV["SPOTIFY_SECRET"]
  end
end
