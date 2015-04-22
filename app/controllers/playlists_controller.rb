class PlaylistsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
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
      @playlist.snapshot_id = response[:snapshot_id]
      @playlist.save!
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
  end
end
