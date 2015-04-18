class Track < ActiveRecord::Base
  belongs_to :group
  has_many :playlists, through: :assignments
  has_many :assignments

  def self.save_tracks(tracklist, group_id)

binding.pry
    tracklist.each_with_index do |song, i|  # REMOVE FIRST
      save_track(song, group_id) if i == 0
    end
    binding.pry # implement save
  end

  def self.save_track(song, group_id)
    track = Track.new
    track.title = song.title
    track.artist_name = song.artist_name
    track.spotify_id  = song.tracks.first.foreign_id
    track.echonest_id = song.id
    track.group_id    = group_id
    if !track.save!
      binding.pry # WTF?
    end
  end

end

  # def add_audio_summary
  #   result = Echowrap.song_search(id: echonest_id,
  #                                 limit: true,
  #                                 results: 1,
  #                                 bucket: ["id:spotify",
  #                                          :song_hotttnesss,
  #                                          :audio_summary]
  #                                 )
  #   binding.pry #check result
  # end
#   def track_to_hash(track)
# binding.pry # text hash, bro
#   end

#   def write_to_file
#     # SKIP IF TRACK ID ALREADY IN SEED FILE
#     ofile = './db/tracks_seed.txt'
#     File.open(ofile,'a+') do |file|
#       file.puts track_to_hash(track)
#     end
#   end
