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
      render "homes/index"
    else
      @playlist = response[:playlist]
      @playlist.snapshot_id = response[:snapshot_id]
      @playlist.save!
      redirect_to @playlist
    end
  end

  def show
    @playlist = Playlist.find(params[:id])
  end
end
