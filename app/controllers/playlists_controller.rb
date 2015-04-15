class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed

  def index
  end

  def create
    @playlist = Playlist.find_or_initialize_by(user: current_user,
                                               seed_artist: params[:playlist])
    @playlist.create_token = session[:token]["number"]
    response = @playlist.build_spotify_playlist

    if response["snapshot_id"]
      @playlist.snapshot_id = response["snapshot_id"]
      @playlist.save!
      flash[:notice] = "Playlist opened"
    else
      flash[:error] = "Failed to create playlist"
    end
    redirect_to @playlist
  end

  private

  # def playlist_params
  #   params.require(:playlist).permit(:seed_artist)
  # end
end
