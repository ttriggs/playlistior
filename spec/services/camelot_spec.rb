require 'rails_helper'

feature 'Camelot class' do
  context 'when given a list of tracks larger than Playlist::SONGS_LIMIT' do
    scenario 'a playlist equal to Playlist::SONGS_LIMIT returns' do
      tracks = MockTrack.get_mock_tracks(Playlist::SONGS_LIMIT + 5)
      uris = ""
      tracklist = Tracklist.new(uris, tracks).setup
      ordered_list = Camelot.new(tracklist).order_tracks
      expect(ordered_list.length).to eq(Playlist::SONGS_LIMIT)
    end
  end

  context 'when given a list of tracks less than Playlist::SONGS_LIMIT' do
    scenario 'a playlist equal to the initial length returns' do
      tracks = MockTrack.get_mock_tracks(Playlist::SONGS_LIMIT - 5)
      uris = ""
      tracklist = Tracklist.new(uris, tracks).setup
      ordered_list = Camelot.new(tracklist).order_tracks
      expect(ordered_list.length).to eq(tracks.length)
    end
  end

  context 'when given an empty list of tracks' do
    scenario 'an empty playlist returns' do
      tracks = []
      uris = ""
      tracklist = Tracklist.new(uris, tracks).setup
      ordered_list = Camelot.new(tracklist).order_tracks
      expect(ordered_list.length).to eq(0)
    end
  end

  context 'when given a list of tracks and a uri list' do
    scenario 'tracks found in the uri list are excluded' do
      tracks = MockTrack.get_mock_tracks(Playlist::SONGS_LIMIT)
      in_use = 5
      tracks_in_use = tracks.take(in_use)
      uris_in_use   = MockTrack.get_uris_from_tracks(tracks_in_use)
      tracklist = Tracklist.new(uris_in_use, tracks).setup
      ordered_list = Camelot.new(tracklist).order_tracks
      ordered_list_uris = ordered_list.map(&:spotify_id)
      expect(ordered_list.length).to eq(tracks.length - in_use)

      ordered_list_uris.each do |uri|
        expect( uris_in_use.include?(uri) ).to be false
      end
    end
  end
end

describe Camelot do
  context '#escalate key' do
    let(:camelot) { Camelot.new("tracklist") }

    it 'returns echonest key number when supplied zone and mode' do
      key_B  = camelot.escalate_key(0, 1)
      key_Eb = camelot.escalate_key(1, 0)
      key_F  = camelot.escalate_key(3, 0)
      key_E  = camelot.escalate_key(11, 1)
      expect(key_B).to eq(11)
      expect(key_Eb).to eq(3)
      expect(key_F).to eq(5)
      expect(key_E).to eq(4)
    end
  end
end
