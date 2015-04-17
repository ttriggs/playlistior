class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed, except: [:show]

  def index
    @playlists = Playlist.all
  end

  def create
    @playlist = Playlist.find_or_initialize_by(user: current_user,
                                               seed_artist: params[:playlist])
    validate_playlist

    response = @playlist.build_spotify_playlist

    if response["snapshot_id"]
      @playlist.snapshot_id = response["snapshot_id"]
      @playlist.save!
      flash[:notice] = "Playlist opened"
      redirect_to @playlist
    else
      flash[:error] = "Failed to create playlist"
      flash[:error] += response
      @playlist.destroy
      render "homes/index"
    end
  end

  def show
    @playlist = Playlist.find(params[:id])
  end

  def validate_playlist
    # binding.pry
    if !@playlist.valid?
      flash[:error] = @playlist.errors.full_messages
      redirect_to root_path
    end
  end

  private

  # def playlist_params
  #   params.require(:playlist).permit(:seed_artist)
  # end
end
