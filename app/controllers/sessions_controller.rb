class SessionsController < ApplicationController
  def new
    redirect_to spotify_auth_url
  end

  def create
    # handle error cases...
    tokens = get_tokens
    user = fetch_or_create_user(get_user_data(tokens["access_token"]))
    session[:user_id] = user.id
    session[:token] = { token: tokens["access_token"],
                        created_at: Time.now,
                        expires: tokens["expires_in"],
                        refresh: tokens["refresh_token"]
                      }
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:info] = "Signed out successfully."
    redirect_to root_path
  end

  def failure
    flash[:alert] = "Unable to sign in."
    redirect_to root_path
  end

  private

  def fetch_or_create_user(user_data)
    user = User.find_or_create_by(email: user_data["email"],
                                  spotify_id: user_data["id"])
    user.spotify_link = user_data["href"]
    user.country = user_data["country"]
    user.name = user_data["display_name"]
    user.image = user_data["images"].first["url"]
    binding.pry
    if user.save
      flash[:info] = "Signed in successfully."
      user
    else
      flash[:notice] = "Error fetching your account data"
      failure
    end
  end

  def get_tokens
    code = params[:code]
    params =  { body: { grant_type: "authorization_code",
                        code: code,
                        redirect_uri: redirect_uri },
               headers: { "Authorization" => "Basic #{encoded_id_and_secret}"}
              }
    post_to_token_url(params)
  end

  def get_user_data(access_token)
    params = { headers: { "Authorization" => "Bearer #{access_token}"} }
    HTTParty.get("https://api.spotify.com/v1/me", params)
  end

  def get_refresh_token
    binding.pry
    params =  { body: { grant_type: "refresh_token",
                        refresh_token: user.refresh_token,
                        redirect_uri: redirect_uri },
               headers: { "Authorization" => "Basic #{encoded_id_and_secret}"}
              }
    post_to_token_url(params)
  end

  def post_to_token_url(params)
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
    CGI.escape("http://localhost:3000/auth/spotify/callback")
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
