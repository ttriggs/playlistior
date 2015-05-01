require 'rails_helper'

feature 'Camelot ordering tracks' do
  context 'when given a list of tracks larger than Playlist::SONGS_LIMIT' do

    scenario 'a playlist equal to Playlist::SONGS_LIMIT returns' do
      tracks = MockTrack.get_mock_tracks(Playlist::SONGS_LIMIT + 5)
      uris = ""
      ordered_list = Camelot.new(uris, tracks).order_tracks
      expect(ordered_list.length).to eq(Playlist::SONGS_LIMIT)
    end
  end

  context 'when given a list of tracks less than Playlist::SONGS_LIMIT' do
    scenario 'a playlist equal to the initial length returns' do
      tracks = MockTrack.get_mock_tracks(Playlist::SONGS_LIMIT - 5)
      uris = ""
      ordered_list = Camelot.new(uris, tracks).order_tracks
      expect(ordered_list.length).to eq(tracks.length)
    end
  end

  context 'when given an empty list of tracks' do
    scenario 'an empty playlist returns' do
      tracks = []
      uris = ""
      ordered_list = Camelot.new(uris, tracks).order_tracks
      expect(ordered_list.length).to eq(0)
    end
  end

  context 'when given a list of tracks and a uri list' do
    scenario 'tracks found in the uri list are excluded' do
      tracks = MockTrack.get_mock_tracks(Playlist::SONGS_LIMIT)
      in_use = 5
      tracks_in_use = tracks.take(in_use)
      uris_in_use   = MockTrack.get_uris_from_tracks(tracks_in_use)
      ordered_list = Camelot.new(uris_in_use, tracks).order_tracks
      ordered_list_uris = ordered_list.map(&:spotify_id)
      expect(ordered_list.length).to eq(tracks.length - in_use)

      ordered_list_uris.each do |uri|
        expect( uris_in_use.include?(uri) ).to be false
      end
    end
  end
end
