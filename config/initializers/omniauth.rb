Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, ENV['SPOTIFY_APP_ID'], ENV['SPOTIFY_SECRET'], scope: 'user-read-email user-read-private playlist-modify-private playlist-read-private'
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
