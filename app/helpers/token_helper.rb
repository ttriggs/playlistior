module TokenHelper

  def setup_new_tokens
    code = params[:code]
    params =  { body: { grant_type: "authorization_code",
                        code: code,
                        redirect_uri: redirect_uri },
               headers: { "Authorization" => "Basic #{encoded_id_and_secret}"}
              }
    tokens = post_for_new_token(params)
    add_token_to_session(tokens)
  end

  def add_token_to_session(tokens)
    session[:token] = { number: tokens["access_token"],
                        created_at: Time.now,
                        expires: tokens["expires_in"],
                        refresh: tokens["refresh_token"]
                      }
  end

  def refresh_token_if_needed
    if session[:token]
      get_refresh_token if need_token_refresh?
    else
      setup_new_tokens
    end
  end

  def need_token_refresh?
    if session[:token]
      expires    = session[:token]["expires"]
      token_created = session[:token]["created_at"]
      seconds_diff  = (Time.now - Time.parse(token_created)).to_i
      # subtract 120s for 2 minute buffer time before token expiration
      seconds_diff >= (expires - 120) ? true : false
    else
      true
    end
  end

  def get_refresh_token
    params =  { body: { grant_type: "refresh_token",
                        refresh_token: session[:token]["refresh"],
                        redirect_uri: redirect_uri },
               headers: { "Authorization" => "Basic #{encoded_id_and_secret}"}
              }
    add_token_to_session(post_for_new_token(params))
  end

  private

  def post_for_new_token(params)
    HTTParty.post(spotify_token_url, params)
  end

  def encoded_id_and_secret
    Base64.strict_encode64("#{client_id}:#{client_secret}")
  end

  def spotify_token_url
    "https://accounts.spotify.com/api/token"
  end

  def spotify_auth_url
    "https://accounts.spotify.com/authorize?client_id=#{client_id}&response_type=code&redirect_uri=#{redirect_uri}&scope=#{scope}"
  end

  def client_id
    ENV["SPOTIFY_APP_ID"]
  end

  def client_secret
    ENV["SPOTIFY_SECRET"]
  end

  def scope
    CGI.escape("user-read-email user-read-private playlist-modify-private playlist-read-private")
  end

  def redirect_uri
    CGI.escape("https://playlistior.herokuapp.com/auth/spotify/callback")
  end
end
