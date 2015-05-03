require 'rails_helper'

describe Playlist do
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
      playlist = MockPlaylist.create(1)
      genres = ["rock", "hip-hop", "soul"]
      playlist.record_music_styles(genres)
      expect(playlist.styles.length).to eq(3)
      expect(playlist.styles.first.genre.name).to eq("rock")
      expect(playlist.styles.second.genre.name).to eq("hip-hop")
      expect(playlist.styles.third.genre.name).to eq("soul")
    end
  end

  describe "#setup_new_tracklist" do
    it "gets new set of 100 tracks for playlist, saves tracks to playlist" do
      playlist = MockPlaylist.create(1)
      orig_track_count = playlist.tracks.length
      playlist.setup_new_tracklist
      new_track_count = playlist.tracks.length
      expect(new_track_count - orig_track_count).to eq(100)
    end
  end

  describe "#add_to_cached_uris location" do
    let(:playlist) { MockPlaylist.create(1) }
    let(:first_uri) { playlist.get_uri_array }
    let(:new_uris)  { ["spotify:track:1234", "spotify:track:5678"] }

    it "appends an array of uris to end of playlist.uri_array" do
      expected_uri_array = first_uri + new_uris
      playlist.add_to_cached_uris(new_uris, "append")
      new_uri_array = playlist.get_uri_array
      expect(expected_uri_array).to eq(new_uri_array)
    end

    it "prepends an array of uris to start of playlist.uri_array" do
      expected_uri_array =  new_uris + first_uri
      playlist.add_to_cached_uris(new_uris, "prepend")
      new_uri_array = playlist.get_uri_array
      expect(expected_uri_array).to eq(new_uri_array)
    end
  end

  describe "#active_tracks_in_order" do
    let(:playlist) { MockPlaylist.create(10) }
    it "returns array of tracks in order specified by uri_array" do
      tracks    = playlist.active_tracks_in_order
      uri_array = playlist.get_uri_array
      tracks.each.with_index(1) do |track_hash, index|
        track = track_hash[:track]
        order = track_hash[:order]
        expect(order).to eq(index)
        expect(uri_array[index - 1]).to eq(track.spotify_id)
      end
    end
  end
end
