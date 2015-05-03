require 'factory_girl'
require_relative 'mock_track'

FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "user #{n}" }
    sequence(:spotify_id) { |n| "spotify_id#{n}" }
    role "user"
  end

  factory :admin, class: User do
    sequence(:name) { |n| "Admin #{n}" }
    spotify_id SecureRandom.hex(6)
    role "admin"
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
    name        "my cool playlist"
    seed_artist "Beck"
    spotify_id  "29831hionfose"
    adventurous false
    snapshot_id "FakeSnapshot_ID"
    link        "/this/bogus/link"
    user
  end

  factory :group do
    rgb "(100, 100, 100)"
  end

  factory :genre do
    name "rock"
    group_id 1
  end
end
