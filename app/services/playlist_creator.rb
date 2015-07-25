class PlaylistCreator
  attr_accessor :playlist, :errors

  def initialize(params, current_user)
    @request = PlaylistRequest.new(params, current_user).prepare_request
    @errors  = @request.errors
  end

  def create
    @playlist = Playlist.fetch_or_build_playlist(@request)
    get_tracks_if_needed
    full_tracklist = Tracklist.new(@playlist.uri_array, @playlist.tracks).setup
    ordered_tracklist = Camelot.new(full_tracklist).order_tracks
    if ordered_tracklist.empty?
      add_error(no_tracks_remain_error)
    else
      add_tracks(ordered_tracklist)
    end
    @playlist.save
    self
  end

  def get_tracks_if_needed
    if @playlist.has_no_tracks?
      get_and_save_new_tracklist
    end
  end

  def get_and_save_new_tracklist
    new_tracklist = EchoNestService.get_new_tracklist(@playlist)
    Track.save_tracks(new_tracklist, @playlist)
  end

  def add_tracks(tracklist)
    track_ids    = build_track_ids(tracklist)
    playlist_url = add_tracks_url
    response     = @playlist.spotify_service.add_tracks(playlist_url, track_ids)
    if response[:errors]
      add_error(response)
    else
      @playlist.update(snapshot_id: response["snapshot_id"])
      @playlist.update_cached_uris(track_ids, location)
      @playlist.clear_cached_charts_json
    end
  end

  def add_error(error_hash)
    @errors.merge!(error_hash)
  end

  def no_tracks_remain_error
    { notice: "Sorry no more tracks found for this playlist" }
  end

  def add_tracks_url
    url = "#{@playlist.link}/tracks"
    location == "prepend" ? url.concat("?position=0") : url
  end

  def build_track_ids(tracklist)
    tracklist.map(&:spotify_id)
  end

  def location
    @request.location
  end

  def no_errors?
    errors.empty?
  end

  def success?
    no_errors?
  end

  def notice?
    errors[:notice].present?
  end

  def exit_error?
    errors[:errors].present?
  end

  def should_destroy?
    !@playlist.nil? && !@playlist.valid?
  end
end
