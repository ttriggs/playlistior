class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :refresh_token_if_needed, except: [:show]

  def create
    playlist = Playlist.find(params[:follow].first)
    follow = Follow.find_or_initialize_by(user_id: current_user.id,
                                          playlist_id: playlist.id)
    if follow.save!
      playlist.increment_followers_cache
      flash[:notice] = "Playlist followed on Playlistior"
    end
    redirect_to playlist
  end

  def destroy
    playlist = Playlist.find(params[:id])
    follow = Follow.find_by(user_id: current_user.id,
                            playlist_id: playlist.id)
    if follow
      playlist.decrement_followers_cache
      follow.destroy
      flash[:notice] = "Unfollowed playlist"
    end
    redirect_to playlist
  end
end
