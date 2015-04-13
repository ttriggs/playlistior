class Camelot
  def initialize
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
                  11 => "B" } #echonest-specific key naming
    @camelot = {["B", 1] => 1,
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

  def get_neighbors(key, mode)
    key = @en_keys[key]
    zone  = @camelot[[key, mode]]
    close_zones = @camelot.select {|k, v| v == zone }
    near_zones = @camelot.select {|k, v| v.between?(zone - 1, zone +1) && k[1] == mode}
    all_zones = close_zones.merge(near_zones).keys
    all_zones.map! {|key, mode| [@en_keys.key(key), mode] }
  end

end
