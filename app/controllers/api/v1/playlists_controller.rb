class Api::V1::PlaylistsController < ApplicationController

  def show
    playlist = Playlist.find(params[:id])
    quality = get_quality_from_params(params[:quality])
    chart_cache_symbol = cache_symbol_from(quality)
    render json: playlist.find_or_create_chart_data(quality, chart_cache_symbol),
           callback: params[:callback]
  end

  private

    def cache_symbol_from(quality)
      (quality.to_s + "_json_cache").to_sym
    end

    def get_quality_from_params(quality)
      quality.nil? ? :energy : quality.to_sym
    end
end
