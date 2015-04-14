class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed

  def index
  end

  def create
    playlist = Playlist.find_or_initialize_by(user: current_user,
                                              seed_artist: params[:playlist])
    playlist.create_token = session[:token]["number"]
    playlist.build_spotify_playlist

    if playlist.save
      playlist.record_styles_for_playlist
      playlist.add_tracks
      flash[:notice] = "Playlist opened"
    else
      flash[:error] = "Failed to create playlist"
    end
  end

  def failure(message="")
    flash[:alert] = "Unable to create playlist. #{message}"
    redirect_to root_path
  end

  private

  # def playlist_params
  #   params.require(:playlist).permit(:seed_artist)
  # end
end
