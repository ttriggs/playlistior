class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed, except: [:show]

  def index
    @playlists = Playlist.all
  end

  def create
    seed_artist = params[:playlist]
    adventurous = params[:adventurous] || false
    response = Playlist.fetch_or_build_playlist(seed_artist,
                                                adventurous,
                                                current_user)
    if response[:errors]
      flash[:error] = response[:errors]
      playlist = response[:playlist]
      playlist.destroy if playlist
      render "homes/index"
    else
      @playlist = response[:playlist]
      @playlist.save!
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

  def show
    @playlist = Playlist.find(params[:id])
    @playlist.setup_uri_array_if_needed
  end
end
