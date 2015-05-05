class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed, except: [:show]

  def index
    @playlists = Playlist.all
  end

  def create
    playlist_creator = PlaylistCreator.new(params, current_user)
    playlist_creator.create if playlist_creator.no_errors?

    if playlist_creator.success?
      flash[:success] = "Playlist generated (updates may appear first in Spotify app :)"
      redirect_to playlist_path(playlist_creator.playlist)
    elsif playlist_creator.notice?
      flash[:notice] = playlist_creator.flash_errors[:notice]
      redirect_to playlist_path(playlist_creator.playlist)
    elsif playlist_creator.exit_error?
      flash[:errors] = playlist_creator.flash_errors[:errors]
      playlist_creator.playlist.destroy if playlist_creator.playlist_invalid?
      redirect_to playlists_path
    end
  end

  def destroy
    @playlist = Playlist.find_by_id(params[:id])
    if @playlist && @playlist.owner_or_admin?(current_user)
      SpotifyService.unfollow_playlist(@playlist, current_user)
      @playlist.destroy
      flash[:success] = "Playlist Deleted"
      redirect_to playlists_path
    else
      redirect_to @playlist || playlists_path
    end
  end

  def show
    @playlist = Playlist.find(params[:id])
  end
end
