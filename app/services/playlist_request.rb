class PlaylistRequest
  attr_reader :user
  attr_accessor :errors

  def initialize(params, current_user)
    @params = params
    @user = current_user
    @errors = {}
  end

  def location
    @location ||= parse_location
  end

  def adventurous
    @adventurous = parse_adventurous
  end

  def artist_data
    @artist_data ||= full_artist_data
  end

  def artist_name
    @artist ||= artist_data[:artist_name]
  end

  def supplied_artist_name
    @supplied_artist_name ||= parse_artist
  end

  def playlist_title
    @playlist_title ||= "Playlistior: #{artist_name}"
  end

  def tempo
    @tempo ||= artist_data[:tempo]
  end

  def familiarity
    @familiarity ||= artist_data[:familiarity]
  end

  def danceability
    @danceability ||= artist_data[:danceability]
  end

  def genres
    @genres ||= artist_data[:genres]
  end

  def prepare_request
    location
    artist_data
    adventurous
    self
  end

  def valid?
    @errors.empty?
  end

  def invalid?
    !valid?
  end

  private

# helpers:
  def full_artist_data
    artist_data = echonest_artist_data
    if valid?
      song_data = echonest_example_song_data
      artist_data.merge!(song_data)
    end
  end

  def add_error(hash)
    @errors = hash.slice(:errors)
  end

# get from echonest:
  def echonest_artist_data
    if supplied_artist_name.blank?
      add_error({ errors: "Seed artist can't be blank" })
    else
      echonest(:get_artist_info)
    end
  end

  def echonest_example_song_data
    echonest(:get_demo_song_data)
  end

  def echonest(method)
    response = EchoNestService.send method, supplied_artist_name
    response[:errors] ? add_error(response) : response
  end

# params parsing:
  def parse_adventurous
    @params[:adventurous] || false
  end

  def parse_artist
    if @params[:playlist].class == Array
      @params[:playlist].first
    else
      @params[:playlist]
    end
  end

  def parse_location
    if @params[:commit] == "Create Playlist"
      "prepend"
    else
      "append"
    end
  end
end
