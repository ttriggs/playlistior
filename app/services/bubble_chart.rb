class BubbleChart
  def initialize(playlist)
    @playlist = playlist
  end

  def create(quality, chart_cache)
    @quality = quality
    chart_data = get_playlist_json
    @playlist.update(chart_cache => JSON(chart_data))
  end

  def get_playlist_json
    @major_series = []
    @minor_series = []
    @playlist.active_tracks_in_order.each do |track_hash|
      track = track_hash[:track]
      order = track_hash[:order]
      camelot_zone = Camelot.get_camelot_zone(track)
      bubble_size = scaled_value(track[@quality])
      if track.mode == 1
        @major_series << [order, camelot_zone, bubble_size]
      else
        @minor_series << [order, camelot_zone, bubble_size]
      end
    end
    format_chart_json
  end

  def format_chart_json
    {
      chart: {
             type: 'bubble',
             zoomType: 'xy'
             },
      title: {
        text: "#{@playlist.seed_artist} playlist visualized"
      },
      subtitle: {
        text: "bubble size: relative song #{@quality.to_s}"
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
          data: @major_series
        },
        {
          name: 'Minor Songs',
          data: @minor_series
        }
      ]
    }
  end

  def scaled_value(value)
    value < 1 ? (value * 100_000).to_i : value
  end
end
