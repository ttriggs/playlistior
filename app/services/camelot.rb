class Camelot
  def initialize(full_tracklist)
    @full_tracklist = full_tracklist
    @en_keys  = { 0 => "C",
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
                  11 => "B" } # echonest-specific key naming
    @circle = { ["B", 1] => 1,
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
  end

  def order_tracks
    tracklist = [take_random(@full_tracklist)]

    until tracklist.length == Playlist::SONGS_LIMIT
      last_song_params = get_key_and_mode(tracklist.last)
      neighbors_params = get_neighbor_params(last_song_params)
      tracklist << get_next_song(neighbors_params)
    end
    tracklist
  end

  def get_neighbor_params(params_array)
    key, mode = params_array
    key = @en_keys[key]
    zone  = @circle[[key, mode]]
    close_zones = @circle.select {|_key, circle_zone| circle_zone == zone }
    near_zones = @circle.select do |key, circle_zone|
      circle_zone.between?(zone - 1, zone +1) && key[1] == mode
    end
    all_zones = close_zones.merge(near_zones).keys
    all_zones.map! {|key, mode| [@en_keys.key(key), mode] }
  end

  def get_key_and_mode(track)
    track.audio_summary.to_hash.values_at("key", "mode")
  end

  def take_random(array)
    array.delete_at(rand(array.length))
  end

  def get_index_of_next_song(song_params)
    key, mode = song_params
    @full_tracklist.find_index do |song|
      song.audio_summary.key == key &&
      song.audio_summary.mode == mode
    end
  end

  def get_next_song(neighbors_params)
    index = get_next_song_index(neighbors_params)
    @full_tracklist.delete_at(index)
  end

  def get_next_song_index(neighbors_params)
    index = -1 # take last if no match
    neighbors_params.shuffle.each do |song_params|
      @full_tracklist.find do |song|
        index = get_index_of_next_song(song_params) || index
      end
      return index if index > -1
    end
    index
  end
end

