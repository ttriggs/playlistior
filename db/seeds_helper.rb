# helper class methods for updating old tables
# canabalized methods from production

class Hlpr
  def self.clear_cached_charts_json(playlist)
    Playlist::CHARTS_CACHES.each do |cached_chart|
      playlist[cached_chart] = nil
    end
    playlist.save!
  end

  def self.get_audio_summaries(playlist)
    key = ENV['ECHONEST_API_KEY']
    base_url = self.song_profile_url
    playlist.get_uri_array.each_slice(20).with_object(complete_songs = []) do |song_batch|
      url = "#{base_url}api_key=#{key}&format=json&"
      url.concat("bucket=audio_summary&bucket=id:spotify&limit=true&bucket=tracks&")
      track_ids_string = self.songs_to_track_id_string(song_batch)
      url.concat(track_ids_string)
      result = HTTParty.get(url)["response"]["songs"]
      if result
        complete_songs.concat(add_audio_summary_data(song_batch, result))
      end
    end
  end

  def self.add_audio_summary_data(song_batch, audio_summaries)
    song_batch.each_with_object([]) do |song_uri, array|
      matched_summary = audio_summaries.find do |summary|
        summary["tracks"].first["foreign_id"] == song_uri
      end
      if matched_summary
        array << matched_summary
      end
    end
  end

  def self.songs_to_track_id_string(uris)
    uris.map do |song|
      "track_id=" + song
    end.join("&")
  end

  def self.song_profile_url
    "http://developer.echonest.com/api/v4/song/profile?"
  end

  def self.do_sleep(seconds=30)
    print "sleeping."
    (1..seconds).each do
      sleep 1
      print "."
    end
    puts ""
  end
end
