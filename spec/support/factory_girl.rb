require 'factory_girl'

FactoryGirl.define do
  factory :user do
    name SecureRandom.hex(10)
  end

  factory :track do
    artist_name "bobs neato band"
    spotify_id "29831hionfose"
    title "my super neato song"
    key 1
    mode 0
    tempo 120
    danceability 0.344
    energy 0.442
    liveness 0.333
    time_signature 4
  end

end
