class Api::V1::PlaylistsController < ApplicationController

  def show
    playlist = Playlist.find(params[:id])
    @playlist_data = get_playlist_json(playlist)

    render json: @playlist_data, callback: params[:callback]
  end

  private

  def get_playlist_json(playlist)
    playlist.setup_uri_array_if_needed(current_user)
    playlist.setup_tracks_if_needed
    active_tracks = playlist.active_tracks_in_order
    @major_series = []
    @minor_series = []
    active_tracks.each.with_index(1) do |track, order|
      circle_zone = Camelot.get_circle_zone(track)
      energy = (track.energy * 100_000).to_i
      if track.key == 1
        @major_series << [order, circle_zone, energy]
      else
        @minor_series << [order, circle_zone, energy]
      end
    end
    create_chart_json(@major_series, @minor_series)
  end

  def create_chart_json(major_series, minor_series)
    {
      chart: {
              type: 'bubble',
              zoomType: 'xy'
             },
             title: { text: 'Highcharts Bubbles' },
            series: [
              { data: major_series },
              { data: minor_series }
                    ]
    }
  end
end
