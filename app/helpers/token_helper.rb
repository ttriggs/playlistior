module TokenHelper
  def add_token_to_session(tokens)
    session[:token] = { number: tokens["access_token"],
                        created_at: Time.now,
                        expires: tokens["expires_in"],
                        refresh: tokens["refresh_token"]
                      }
  end

  def refresh_token_if_needed
    if need_token_refresh?
      add_token_to_session(TokenService.refresh_token)
    end
  end

  def setup_new_tokens(code)
    add_token_to_session(TokenService.new_tokens(code))
  end

  def need_token_refresh?
    if session[:token]["refresh"]
      expires    = session[:token]["expires"]
      token_created = session[:token]["created_at"]
      seconds_diff  = (Time.now - Time.parse(token_created)).to_i
      # subtract 120s for 2 minute buffer time before token expiration
      seconds_diff >= (expires - 120) ? true : false
    else
      true
    end
  end
end
