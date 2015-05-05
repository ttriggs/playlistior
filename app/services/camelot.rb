class Camelot
    # echonest-specific key naming
    EN_KEYS  = { 0 => "C",
                  1 => "Db",
                  2 => "D",
                  3 => "Eb",
                  4 => "E",
                  5 => "F",
                  6 => "F#",
                  7 => "G",
                  8 => "Ab",
                  9 => "A",
                  10 => "Bb",
                  11 => "B" }
    # coded circle of fifths
    CIRCLE = { ["B", 1] => 1,
                 ["Ab", 0] => 1,
                 ["F#", 1] => 2,
                 ["Eb", 0] => 2,
                 ["Db", 1] => 3,
                 ["Bb", 0] => 3,
                 ["Ab", 1] => 4,
                 ["F", 0] => 4,
                 ["Eb", 1] => 5,
                 ["C", 0] => 5,
                 ["Bb", 1] => 6,
                 ["G", 0] => 6,
                 ["F", 1] => 7,
                 ["D", 0] => 7,
                 ["C", 1] => 8,
                 ["A", 0] => 8,
                 ["G", 1] => 9,
                 ["E", 0] => 9,
                 ["D", 1] => 10,
                 ["B", 0] => 10,
                 ["A", 1] => 11,
                 ["F#", 0] => 11,
                 ["E", 1] => 12,
                 ["Db", 0] => 12 }

  def initialize(uris, tracks)
    @uris = uris
    @full_tracklist = get_array_of_new_tracks(tracks)
  end

  def get_array_of_new_tracks(tracks)
    tracks.each_with_object(new_tracks = []) do |track|
      unless @uris.include?(track.spotify_id.to_s)
        new_tracks << track
      end
    end
  end

  def order_tracks
    return @full_tracklist if @full_tracklist.empty?
    tracklist = [take_random(@full_tracklist)]
    until hit_song_limit?(tracklist)
      last_song_params = get_key_and_mode(tracklist.last)
      neighbors_params = get_neighbor_params(last_song_params)
      tracklist << get_next_song(neighbors_params)
    end
    tracklist
  end

  def hit_song_limit?(tracklist)
    tracklist.length == Playlist::SONGS_LIMIT ||
      @full_tracklist.empty?
  end

  def get_neighbor_params(params_array)
    track_key, mode = params_array
    key = EN_KEYS[track_key]
    zone  = CIRCLE[[key, mode]]
    close_zones = CIRCLE.select {|_key, circle_zone| circle_zone == zone }
    near_zones = CIRCLE.select do |key, circle_zone|
      circle_zone.between?(zone - 1, zone +1) && key[1] == mode
    end
    all_zones = close_zones.merge(near_zones).keys
    all_zones.map! {|key, mode| [EN_KEYS.key(key), mode] }
  end

  def get_key_and_mode(track)
    [track.key, track.mode]
  end

  def take_random(array)
    array.delete_at(rand(array.length))
  end

  def next_song_by_params(song_params)
    key, mode = song_params
    @full_tracklist.find_index do |song|
      song.key == key &&
      song.mode == mode
    end
  end

  def get_next_song(neighbors_params)
    index = -1
    neighbors_params.shuffle.each do |song_params|
      index = next_song_by_params(song_params) || -1
      return take_song(index) if index > -1
    end
    take_song(index)
  end

  def take_song(index)
    @full_tracklist.delete_at(index)
  end

  def self.get_circle_zone(track)
    key = EN_KEYS[track.key]
    CIRCLE[[key, track.mode]]
  end
end
