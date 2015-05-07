class MockTrack
  TRACKS_FILE = File.expand_path("../example_tracks.json", __FILE__)

  TRACKS_JSON = File.read(TRACKS_FILE)
  TRACKS_HASH = JSON.parse(TRACKS_JSON)
  attr_reader :artist_name, :echonest_id, :spotify_id, :title, :tracks,
              :key, :mode, :energy, :danceability, :audio_summary, :id

  def initialize(track_data)
    @id = track_data["echonest_id"]
    @key = track_data["key"]
    @mode = track_data["mode"]
    @title = track_data["title"]
    @tempo = track_data["tempo"]
    @energy = track_data["energy"]
    @liveness = track_data["liveness"]
    @spotify_id = track_data["spotify_id"]
    @artist_name = track_data["artist_name"]
    @echonest_id = track_data["echonest_id"]
    @danceability = track_data["danceability"]
    @time_signature = track_data["time_signature"]
    #for flexible use w/ track model:
    @tracks = [{ foreign_id: @spotify_id, id: @echonest_id }]
    @audio_summary = {"key" => @key,
                      "mode" => @mode,
                      "tempo" => @tempo,
                      "energy" => @energy,
                      "liveness" => @liveness,
                      "danceability" => @danceability,
                      "time_signature" => @time_signature }
  end


  def self.get_mock_track(index=0)
    track_data = TRACKS_HASH[index]
    track = MockTrack.new(track_data) if track_data
  end

  def self.get_mock_tracks(n)
    (0..n-1).each_with_object(tracks = []) do |index|
      new_track = get_mock_track(index)
      tracks += [new_track]  if new_track
    end
    tracks
  end

  def self.get_saved_track(index=0)
    mock_track = get_mock_track(index)
    track = Track.find_or_create_track(mock_track) if mock_track
  end

  def self.get_saved_tracks(n)
    (0..n-1).each_with_object(tracks = []) do |index|
      new_track = get_saved_track(index)
      tracks += [new_track]  if new_track
    end
    tracks
  end

  def self.get_uris_from_tracks(tracks)
    tracks.map(&:spotify_id).to_s
  end

  def update(hash)
    # do nothing here...
  end

end
