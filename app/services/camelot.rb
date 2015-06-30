class Camelot
    # echonest-specific key naming
    EN_KEYS  = {
                 0 => "C",
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
                 11 => "B"
               }
    # coded circle of fifths
    CIRCLE = {
               ["B", 1] => 0,
               ["Ab", 0] => 0,
               ["F#", 1] => 1,
               ["Eb", 0] => 1,
               ["Db", 1] => 2,
               ["Bb", 0] => 2,
               ["Ab", 1] => 3,
               ["F", 0] => 3,
               ["Eb", 1] => 4,
               ["C", 0] => 4,
               ["Bb", 1] => 5,
               ["G", 0] => 5,
               ["F", 1] => 6,
               ["D", 0] => 6,
               ["C", 1] => 7,
               ["A", 0] => 7,
               ["G", 1] => 8,
               ["E", 0] => 8,
               ["D", 1] => 9,
               ["B", 0] => 9,
               ["A", 1] => 10,
               ["F#", 0] => 10,
               ["E", 1] => 11,
               ["Db", 0] => 11
             }

  def initialize(full_tracklist, selection_method = :wander)
    @full_tracklist = full_tracklist
    @selection_method = selection_method
  end

  def order_tracks
    return [] if @full_tracklist.empty?
    tracklist = [@full_tracklist.take_random]
    until hit_song_limit?(tracklist)
      @last_song_params = get_key_and_mode(tracklist.last)
      @last_song_zone   = Camelot.get_camelot_zone(tracklist.last)
      @neighbors_params = get_neighbor_params_array
      next_song = get_next_song
      tracklist << next_song
    end
    tracklist
  end

  def hit_song_limit?(tracklist)
    tracklist.length == Playlist::SONGS_LIMIT ||
      @full_tracklist.empty?
  end

  def get_neighbor_params_array
    track_key, mode = @last_song_params
    key  = EN_KEYS[track_key]
    zone = CIRCLE[[key, mode]]
    close_zones = CIRCLE.select {|_key, circle_zone| circle_zone == zone }
    adjacent_zones = CIRCLE.select do |key, circle_zone|
      circle_zone.between?(zone - 1, zone +1) && key[1] == mode
    end
    all_zones = close_zones.merge(adjacent_zones).keys
    all_zones.map! {|key, mode| [EN_KEYS.key(key), mode] }
  end

  def get_key_and_mode(track)
    [track.key, track.mode]
  end

  def next_song_by_params(song_params)
    key, mode = song_params
    @full_tracklist.find_index do |song|
      song.key == key &&
      song.mode == mode
    end
  end

  def get_next_song
    next_song = method(@selection_method).call
    if next_song.class != Track
      next_song = @full_tracklist.take_random
    end
    next_song
  end

  def escalator
    next_zone = (@last_song_zone + 1 ) % 12
    next_mode = @last_song_params[1]
    next_key  = escalate_key(next_zone, next_mode)
    next_song_params = [next_key, next_mode]
    if @full_tracklist.track_exists?(next_song_params)
      @full_tracklist.take_track(next_song_params)
    else
      wander
    end
  end

  def escalate_key(next_zone, next_mode)
    zone = CIRCLE.select do |key, zone|
      zone == next_zone && key[1] == next_mode
    end
    EN_KEYS.invert[zone.keys.first[0]]
  end

  def wander
    @neighbors_params.shuffle.each do |song_params|
      if @full_tracklist.track_exists?(song_params)
        return @full_tracklist.take_track(song_params)
      end
    end
  end

  def self.get_camelot_zone(track)
    key = EN_KEYS[track.key]
    CIRCLE[[key, track.mode]]
  end
end
