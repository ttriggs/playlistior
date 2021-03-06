require 'factory_girl'
require_relative 'mock_track'

FactoryGirl.define do

  factory :user do
    sequence(:name) { |n| "user #{n}" }
    sequence(:spotify_id) { |n| "spotify_id#{n}" }
    role "user"
    spotify_link "http://my/spotify_link"
    image "http://this/image/path.png"
  end

  factory :guest do
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

  factory :playlist do
    name        "Playlistior: Beck"
    seed_artist "Beck"
    adventurous  false
    snapshot_id "FakeSnapshot_ID"
    link        "v1/users/TestUser123/playlists/3P95eDoSwbtMrJRF4lOAdn"
    follows_cache 0
    user
  end

  factory :group do
    rgb "(100, 100, 100)"
  end

  factory :genre do
    name "alternative rock"
    group_id 1
  end
end
