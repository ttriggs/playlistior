
puts "ADDING GENRES TO DB:"
ifile = './lib/assets/generes_by_popularity.csv'
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



