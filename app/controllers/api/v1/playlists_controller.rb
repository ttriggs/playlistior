class Api::V1::PlaylistsController < ApplicationController

  def show
    playlist = Playlist.find(params[:id])
    type = :energy # change later to be a user-defined input
    json_cache_symbol = type_to_json_cache_symbol(type)
    if playlist[json_cache_symbol]
      @playlist_data = playlist[json_cache_symbol]
    else
      @playlist_data = get_playlist_json(playlist, :energy)
      playlist[json_cache_symbol] = JSON(@playlist_data)
      playlist.save! # move this to model later
    end
    render json: @playlist_data, callback: params[:callback]
  end

  private

  def get_playlist_json(playlist, type=:energy)
    # playlist.setup_uri_array_if_needed(current_user)
    active_tracks = playlist.active_tracks_in_order
    @major_series = []
    @minor_series = []
    active_tracks.each do |track_hash|
      track = track_hash[:track]
      order = track_hash[:order]
      circle_zone = Camelot.get_circle_zone(track)
      energy = scaled_value(track[type])
      if track.key == 1
        @major_series << [order, circle_zone, energy]
      else
        @minor_series << [order, circle_zone, energy]
      end
    end
    create_chart_json(playlist, type, @major_series, @minor_series)
  end

  def create_chart_json(playlist, type, major_series, minor_series)
    {
      chart: {
             type: 'bubble',
             zoomType: 'xy'
             },
      title: {
        text: "#{playlist.seed_artist} playlist visualized"
      },
      subtitle: {
        text: "bubble size: relative song #{type.to_s}"
      },
      xAxis: {
        title: { text: 'Play Order' }
      },
      yAxis: {
         allowDecimals: false,
         title: { text: 'Camelot Zone' }
      },
      series: [
        {
          name: 'Major Songs',
          data: major_series
        },
        {
          name: 'Minor Songs',
          data: minor_series
        }
      ]
    }
  end

  def type_to_json_cache_symbol(type)
    (type.to_s + "_json_cache").to_sym
  end

  def scaled_value(value)
    (value * 100_000).to_i
  end
end
