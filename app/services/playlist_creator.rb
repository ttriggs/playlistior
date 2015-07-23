class PlaylistCreator
  attr_accessor :playlist, :errors

  def initialize(request)
    @request = request
    @errors = request.errors
    @location = @request.location
    # @playlist_params = get_playlist_params(artist_from(params))
    # demo_song_params = get_demo_song_params if no_errors?
    if no_errors?
#       @playlist_params.merge!(demo_song_params)
#       @playlist_params.merge!(adventurous: adventurous_from(params))
# binding.pry
      # @playlist = Playlist.fetch_or_build_playlist(@playlist_params, current_user)
      @playlist = Playlist.fetch_or_build_playlist(request)
    end
  end

  def create
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
    playlist_url = add_tracks_url(@location)
    response     = @playlist.spotify_service.add_tracks(playlist_url, track_ids)
    if response[:errors]
      add_error(response)
    else
      @playlist.update(snapshot_id: response["snapshot_id"])
      @playlist.update_cached_uris(track_ids, @location)
      @playlist.clear_cached_charts_json
    end
  end

  def add_error(error_hash)
    @errors.merge!(error_hash)
  end

  def no_tracks_remain_error
    { notice: "Sorry no more tracks found for this playlist" }
  end

  def add_tracks_url(location)
    url = "#{@playlist.link}/tracks"
    location == "prepend" ? url.concat("?position=0") : url
  end

  def build_track_ids(tracklist)
    tracklist.map(&:spotify_id)
  end

  def no_errors?
    @errors.empty?
  end

  def success?
    flash_errors.empty?
  end

  def notice?
    flash_errors[:notice].present?
  end

  def exit_error?
    flash_errors[:errors].present?
  end

  def flash_errors
    if playlist_invalid?
      @errors.merge!({ errors: @playlist.errors })
    else
      @errors
    end
  end

  def playlist_invalid?
    !@playlist.nil? && !@playlist.valid?
  end

  private

  # def get_playlist_params(artist)
  #   if !artist.blank?
  #     response = EchoNestService.get_artist_info(artist)
  #     response[:errors] ? add_error(response) : response
  #   else
  #     @errors = { errors: "Seed artist can't be blank" }
  #   end
  # end

  # def get_demo_song_params
  #   artist = @playlist_params[:artist_name]
  #   response = EchoNestService.get_demo_song_data(artist)
  # end

  # def adventurous_from(params)
  #   params[:adventurous] || false
  # end

  # def artist_from(params)
  #   if params[:playlist].class == Array
  #     params[:playlist].first
  #   else
  #     params[:playlist]
  #   end
  # end

  # def location_from(params)
  #   if params[:commit] == "Create Playlist"
  #     "prepend"
  #   else
  #     "append"
  #   end
  # end
end
