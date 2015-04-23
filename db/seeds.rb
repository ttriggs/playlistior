
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
puts ""

#add follows to playlists created before follows_cache migration:
Playlist.all.each do |playlist|
  if playlist.follows_cache == 0
    playlist.follows_cache = Follow.where(playlist_id: playlist.id).count
    playlist.save!
    puts "pf+"
  end
end
