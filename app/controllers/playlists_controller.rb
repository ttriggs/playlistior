class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed, except: [:show]

  def index
    @playlists = Playlist.all
  end

  def create
    seed_artist = get_seed_artist(params)
    location = get_location_from_params(params)
    adventurous = params[:adventurous] || false
    response = Playlist.fetch_or_build_playlist(seed_artist,
                                                adventurous,
                                                current_user,
                                                location)
    if response[:errors]
      flash[:error] = response[:errors]
      playlist = response[:playlist]
      playlist.destroy if playlist
      render "homes/index"
    elsif response[:notice]
      flash[:notice] = response[:notice]
      playlist = response[:playlist]
      redirect_to playlist
    else
      @playlist = response[:playlist]
      @playlist.save!
      @playlist.clear_cached_charts_json
      flash[:success] = "Playlist created (updates may appear first in Spotify app :)"
      redirect_to @playlist
    end
  end

  def destroy
    @playlist = Playlist.find(params[:id])
    if @playlist.owner?(current_user)
      ApiWrap.unfollow_playlist(@playlist, current_user)
      @playlist.destroy
      flash[:success] = "Playlist Deleted"
      redirect_to playlists_path
    else
      redirect_to @playlist
    end
  end

  def update
    playlist = Playlist.find(params[:id])
    if playlist.owner_or_admin?(current_user)
      seed_artist = playlist.seed_artist
      adventurous = playlist.adventurous
      user_id = playlist.user_id
      location = "append"
      if current_user.id == user_id
        ApiWrap.unfollow_playlist(playlist, current_user)
      end
      playlist.delete
      response = Playlist.fetch_or_build_playlist(seed_artist,
                                                  adventurous,
                                                  current_user,
                                                  location)
      if response[:errors]
        flash[:error] = response[:errors]
        new_playlist = response[:playlist]
        new_playlist.destroy if new_playlist
  binding.pry # wut.
        render "homes/index"
      elsif response[:notice]
        flash[:notice] = response[:notice]
        new_playlist = response[:playlist]
        redirect_to new_playlist
      else
        @playlist = response[:playlist]
        @playlist.user_id = user_id # restore original owner
        @playlist.save!
        @playlist.clear_cached_charts_json
        flash[:success] = "Playlist created (updates may appear first in Spotify app :)"
        redirect_to @playlist
      end
    end
  end

  def show
    @playlist = Playlist.find(params[:id])
    @playlist.setup_uri_array_if_needed(current_user)
  end

  private

  def get_seed_artist(params)
    if params[:playlist].class == Array
      params[:playlist].first.titleize
    else
      params[:playlist].titleize
    end
  end

  def get_location_from_params(params)
    if params[:commit] == "Create Playlist"
      "prepend"
    else
      "append"
    end
  end
end
