class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed, except: [:show]

  def index
    @playlists = Playlist.all
  end

  def create
    playlist_creator = PlaylistCreator.new(params, current_user)
    playlist_creator.create if playlist_creator.no_errors?
    set_flash(playlist_creator.errors)
    if playlist_creator.success?
      redirect_to playlist_path(playlist_creator.playlist)
    elsif playlist_creator.notice?
      redirect_to playlist_path(playlist_creator.playlist)
    elsif playlist_creator.exit_error?
      playlist_creator.playlist.destroy if playlist_creator.should_destroy?
      redirect_to playlists_path
    end
  end
  
  def destroy
    @playlist = Playlist.find_by_id(params[:id])
    if @playlist && @playlist.owner_or_admin?(current_user)
      SpotifyService.unfollow_playlist(@playlist.spotify_id,
                                        current_user.spotify_id,
                                        current_user.session_token)
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

  private

  def set_flash(flash_errors)
    if flash_errors[:errors]
      flash[:errors] = flash_errors[:errors]
    elsif flash_errors[:notice]
      flash[:notice] = flash_errors[:notice]
    else
      flash[:success] = "Playlist generated (updates may appear first in Spotify app :)"
    end
  end
end
