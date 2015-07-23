class PlaylistRequest
  attr_reader :errors, :user

  def initialize(params, current_user)
    @params = params
    @user = current_user
    @errors = {}
  end

  def location
    @location ||= location_from_params
  end

  def adventurous
    @adventurous = adventurous_from_params
  end

  def artist_data
    @artist_data ||= full_artist_data
  end

  def artist_name
    @artist ||= artist_from_params
  end

  def playlist_title
    @playlist_title ||= "Playlistior: #{artist_name}"
  end

  def tempo
    @tempo = artist_data[:tempo]
  end

  def familiarity
    @familiarity = artist_data[:familiarity]
  end

  def danceability
    @danceability = artist_data[:danceability]
  end

  def genres
    @genres = artist_data[:genres]
  end

  def prepare_request
    location
    artist_data
    adventurous
    self
  end

  def invalid?
    !@errors.empty?
  end

  private

#helpers:

  def full_artist_data
    artist_data = echonest_artist_data
    unless invalid?
      song_data = echonest_example_song_data
      artist_data.merge!(song_data)
    end
  end

  def example_song_data
    @example_song_data ||= echonest_example_song_data
  end

  def add_error(error_hash)
    @errors.merge!(error_hash.slice(:errors))
  end

#get from echonest:
  def echonest_artist_data
    if artist_name.blank?
      @errors = { errors: "Seed artist can't be blank" }
    else
      response = EchoNestService.get_artist_info(artist_name)
      response[:errors] ? add_error(response) : response
    end
  end

  def echonest_example_song_data
    response = EchoNestService.get_demo_song_data(artist_name)
    response[:errors] ? add_error(response) : response
  end

#params parsing:
  def adventurous_from_params
    @params[:adventurous] || false
  end

  def artist_from_params
    if @params[:playlist].class == Array
      @params[:playlist].first
    else
      @params[:playlist]
    end
  end

  def location_from_params
    if @params[:commit] == "Create Playlist"
      "prepend"
    else
      "append"
    end
  end
end
