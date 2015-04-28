
# if old tables are missing datapoints or tacks are not linked to playlists
# these are to update older versions of playlistor
# to save track data for use in charts
require_relative 'seeds_helper.rb'
require_relative 'update_tables.rb'


puts "ADDING GENRES TO DB:"
ifile = './db/genres_by_popularity.csv'
File.open(ifile).readlines.each do |line|
  name, popularity, g1, g2, g3 = line.chomp.split(",")
  group_name = "#{g1}" + "#{g2}" + "#{g3}"
  group = Group.find_or_create_by(rgb: group_name)

  Genre.find_or_create_by(name: name,
                          popularity: popularity,
                          group: group )
  print "+"
end

# initialize catch-all group for genres not in my seed file:
Group.find_or_create_by(rgb: "(100, 100, 100)")
Genre.find_or_create_by(name: "melancholia")


all_playlists = Playlist.all
if all_playlists.any?
  #add follows to playlists created before follows_cache migration:
  all_playlists.each do |playlist|
    if playlist.follows_cache == 0
      playlist.follows_cache = Follow.where(playlist_id: playlist.id).count
      playlist.save!
      print "pf+"
    end
  end

  puts ">>>  record tracks for old playlists"
  all_playlists.each do |playlist|
    if playlist.has_no_tracks?
      playlist.setup_new_tracklist
      Hlpr.do_sleep(40)
    else
      puts ">>>  no need to update tracks"
    end
    puts "pt+"
  end

  # record tracks for old playlists
  all_playlists.each do |playlist|
    playlist.seed_artist = playlist.seed_artist.titleize
    playlist.save!
    puts "pSA+ "
  end
end
puts "DONE"

