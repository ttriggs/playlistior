class Api::V1::PlaylistsController < ApplicationController

  def show
    playlist = Playlist.find(params[:id])
    quality = get_quality_from_params(params[:quality])
    render json: playlist.find_or_create_chart_data(quality),
           callback: params[:callback]
  end

  private

  def get_quality_from_params(quality)
    quality.nil? ? :energy : quality.to_sym
  end
end
