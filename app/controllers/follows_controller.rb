class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed, except: [:show]

  def create
    playlist = Playlist.find(params[:follow].first)
    follow = Follow.find_or_initialize_by(user_id: current_user.id,
                                          playlist_id: playlist.id)
    # ApiWrap.follow_playlist(playlist, current_user)
    if follow.save!
      flash[:notice] = "Playlist followed on Playlistior"
    else
      flash[:notice] = "Failed to follow playlist"
    end
    redirect_to playlist
  end

  def destroy
    playlist = Playlist.find(params[:id])
    follow = Follow.find_by(user_id: current_user.id,
                            playlist_id: playlist.id)
    if follow
      follow.destroy
      flash[:notice] = "Unfollowed playlist"
    end
    redirect_to playlist
  end
end
