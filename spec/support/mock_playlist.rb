class MockPlaylist

  def self.create(n)
    playlist = FactoryGirl.create(:playlist)
    (0..n - 1).each do |mocktrack_index|
      add_track_to_playlist(playlist, mocktrack_index)
    end
    playlist
  end

  def self.add_track_to_playlist(playlist, mocktrack_index)
    track = MockTrack.get_saved_track(mocktrack_index)
    playlist.tracks += [track]
    playlist.add_to_cached_uris([track.spotify_id], "append")
  end
end
