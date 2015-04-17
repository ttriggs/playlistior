class PlaylistsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed, except: [:show]

  def index
    @playlists = Playlist.all
  end

  def create
    @playlist = Playlist.find_or_initialize_by(user: current_user,
                                               seed_artist: params[:playlist])
    if @playlist.valid? # either old playlist or they actually entered a seed artist
      response = @playlist.build_spotify_playlist
      @playlist.snapshot_id = response["snapshot_id"]
      @playlist.save!
      flash[:notice] = "Playlist opened"
      redirect_to @playlist
    else # nil user or seed artist
      flash[:error] = @playlist.errors.full_messages
      @playlist.destroy
      render "homes/index"
    end
  end


  def show
    @playlist = Playlist.find(params[:id])
  end
end
  # def validated_playlist?
  #   if !@playlist.valid?
  #     @response = @playlist.errors.full_messages
  #   else
  #     true
  #   end
  # end

  # private

  # def playlist_params
  #   params.require(:playlist).permit(:seed_artist)
  # end
#     if @playlist.valid?
#       response = @playlist.build_spotify_playlist
#     else
#       flash[:error] = @playlist.errors.full_messages
#     end
# binding.pry
#     if response["snapshot_id"]
#       @playlist.snapshot_id = response["snapshot_id"]
#       @playlist.save!
#       flash[:notice] = "Playlist opened"
#       redirect_to @playlist
#     else
#       @playlist.destroy
#       render "homes/index"
#     end
