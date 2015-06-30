class Tracklist
  attr_accessor :tracks

  def initialize(uris, all_tracks)
    @uris = uris
    @all_tracks = all_tracks
    @tracks
  end

  def setup
    filter_out_tracks_in_use
    @tracks = sort_and_group_tracks_by_key
    self
  end

  def track_exists?(track_params)
    @tracks.has_key?(track_params)
  end

  def empty?
    @tracks.values.flatten.length == 0
  end

  def take_random
    take_track(@tracks.keys.sample)
  end

  def take_track(track_params)
    track = @tracks[track_params].delete_at(0)
    @tracks.delete(track_params) if @tracks[track_params].empty?
    track
  end

  private

  def filter_out_tracks_in_use
    @all_tracks.each_with_object(@tracks = []) do |track|
      unless @uris.include?(track.spotify_id.to_s)
        @tracks << track
      end
    end
  end

  def sort_and_group_tracks_by_key
    @tracks.sort_by(&:key).group_by { |song| [song.key, song.mode] }
  end
end
