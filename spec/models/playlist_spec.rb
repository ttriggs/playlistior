require 'rails_helper'

describe Playlist do
  let(:playlist) { FactoryGirl.create(:playlist) }
  let(:playlist_no_tracks) { MockPlaylist.create(0) }
  let(:playlist_one_track) { MockPlaylist.create(1) }
  let(:playlist_ten_tracks) { MockPlaylist.create(10) }
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:user, role: "admin") }

  describe "validations" do
    it { should  have_many(:genres) }
    it { should  have_many(:styles) }
    it { should  have_many(:tracks) }
    it { should  have_many(:follows) }
    it { should  have_many(:assignments) }
    it { should  belong_to(:user) }

    it { should validate_presence_of(:seed_artist) }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:spotify_id) }
    it { should validate_presence_of(:link) }
  end

  describe "#record_music_styles" do
    it "records genres for playlist when given array of genres" do
      genres = ["rock", "hip-hop", "soul"]
      playlist_one_track.record_music_styles(genres)
      expect(playlist_one_track.styles.length).to eq(3)
      expect(playlist_one_track.styles.first.genre.name).to eq("rock")
      expect(playlist_one_track.styles.second.genre.name).to eq("hip-hop")
      expect(playlist_one_track.styles.third.genre.name).to eq("soul")
    end
  end

  describe "#add_to_cached_uris location" do
    let(:first_uri) { playlist_one_track.get_uri_array }
    let(:new_uris)  { ["spotify:track:1234", "spotify:track:5678"] }

    it "appends an array of uris to end of playlist.uri_array" do
      expected_uri_array = first_uri + new_uris
      playlist_one_track.add_to_cached_uris(new_uris, "append")
      new_uri_array = playlist_one_track.get_uri_array
      expect(expected_uri_array).to eq(new_uri_array)
    end

    it "prepends an array of uris to start of playlist.uri_array" do
      expected_uri_array =  new_uris + first_uri
      playlist_one_track.add_to_cached_uris(new_uris, "prepend")
      new_uri_array = playlist_one_track.get_uri_array
      expect(expected_uri_array).to eq(new_uri_array)
    end
  end

  describe "#active_tracks_in_order" do
    it "returns array of tracks in order specified by uri_array" do
      tracks    = playlist_ten_tracks.active_tracks_in_order
      uri_array = playlist_ten_tracks.get_uri_array
      tracks.each.with_index(1) do |track_hash, index|
        track = track_hash[:track]
        order = track_hash[:order]
        expect(order).to eq(index)
        expect(uri_array[index - 1]).to eq(track.spotify_id)
      end
    end
  end

  describe "#owner_or_admin?" do
    it "returns true if owner or admin is passed" do
      admin_response = playlist.owner_or_admin?(admin)
      owner_response = playlist.owner_or_admin?(playlist.user)
      visitor_response = playlist.owner_or_admin?(user)
      expect(admin_response).to be
      expect(owner_response).to be
      expect(visitor_response).to_not be
    end
  end

  describe "#(inc/dec)rement_followers_cache" do
    it "for new follower, add to follower cache" do
      before_inc = playlist.follows_cache
      playlist.increment_followers_cache
      after_inc = playlist.follows_cache
      expect(after_inc - before_inc).to eq(1)

      playlist.decrement_followers_cache
      after_dec = playlist.follows_cache
      expect(before_inc).to eq(after_dec)
    end
  end

  describe "#has_snapshot?" do
    it "returns true if snapshot not nil" do
      with_snapshot = playlist.has_snapshot?
      expect(with_snapshot).to be
    end

    it "returns fasle if snapshot is nil" do
      playlist.snapshot_id = nil
      without_snapshot = playlist.has_snapshot?
      expect(without_snapshot).to_not be
    end
  end

  describe "#has_no_tracks?" do
    it "returns true if playlist has not tracks associated" do
      without_tracks = playlist.has_no_tracks?
      expect(without_tracks).to be
    end

    it "returns false when playlist has > 0 tracks" do
      with_tracks = playlist_one_track.has_no_tracks?
      expect(with_tracks).to_not be
    end
  end

  describe "#fresh_playlist?" do
    it "returns true if has_no_tracks? or nil snapshot_id" do
      without_tracks = playlist.fresh_playlist?
      playlist_one_track.snapshot_id = nil
      without_snapshot = playlist_one_track.fresh_playlist?

      expect(without_tracks).to be
      expect(without_snapshot).to be
    end

    it "returns false if has tracks && snapshot_id present" do
      with_both = playlist_one_track.fresh_playlist?
      expect(with_both).to_not be
    end
  end

  describe "#clear_cached_charts_json" do
    it "sets all cached chart data to nil" do
      fake_data = "{super,fake,json,chart,data}"
      Playlist::CHARTS_CACHES.each do |cache|
        playlist[cache] = fake_data
      end
      before_clear = playlist.energy_json_cache

      playlist.clear_cached_charts_json

      expect(before_clear).to include(fake_data)

      Playlist::CHARTS_CACHES.each do |cache|
        expect(playlist[cache]).to eq(nil)
      end
    end
  end

  describe "#setup_tracks_if_needed #setup_new_tracklist" do
    it "gets new set of 100 tracks if playlist has no tracks, saves tracks" do
      playlist = playlist_no_tracks
      orig_track_count = playlist.tracks.length
      playlist.setup_tracks_if_needed
      new_track_count = playlist.tracks.length
      expect(new_track_count - orig_track_count).to eq(100)
    end

    it "skips setup if playlist already has tracks associated" do
      playlist = playlist_one_track
      orig_track_count = playlist.tracks.length
      playlist.setup_tracks_if_needed
      new_track_count = playlist.tracks.length
      expect(new_track_count - orig_track_count).to eq(0)
    end
  end
end
