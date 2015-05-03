class TokenWrap

  def self.get_new_tokens(code)
    params =  { body: { grant_type: "authorization_code",
                        code: code,
                        redirect_uri: redirect_uri },
               headers: { "Authorization" => "Basic #{encoded_id_and_secret}"}
              }
    post_for_new_tokens(params)
  end

  # def self.refresh_token_if_needed
  #   if session[:token]
  #     self.get_refresh_token if need_token_refresh?
  #   else
  #     self.setup_new_tokens
  #   end
  # end

  # def self.need_token_refresh?
  #   if session[:token]["refresh"]
  #     expires  = session[:token]["expires"]
  #     token_created = session[:token]["created_at"]
  #     seconds_diff  = (Time.now - Time.parse(token_created)).to_i
  #     # subtract 120s for 2 minute buffer time before token expiration
  #     seconds_diff >= (expires - 120) ? true : false
  #   else
  #     true
  #   end
  # end

  # def self.add_token_to_session(tokens)
  #   session[:token] = { number: tokens["access_token"],
  #                       created_at: Time.now,
  #                       expires: tokens["expires_in"],
  #                       refresh: tokens["refresh_token"]
  #                     }
  # end


  def self.get_refresh_token
    params =  { body: { grant_type: "refresh_token",
                        refresh_token: session[:token]["refresh"],
                        redirect_uri: self.redirect_uri },
               headers: { "Authorization" => "Basic #{encoded_id_and_secret}"}
              }
    post_for_new_tokens(params)
  end

  private

  def self.post_for_new_tokens(params)
    return HTTParty.post(spotify_token_url, params)
  end

  def self.encoded_id_and_secret
    Base64.strict_encode64("#{client_id}:#{client_secret}")
  end

  def self.spotify_token_url
    "https://accounts.spotify.com/api/token"
  end

  def self.spotify_auth_url
    "https://accounts.spotify.com/authorize?client_id=#{client_id}&response_type=code&redirect_uri=#{redirect_uri}&scope=#{scope}"
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
