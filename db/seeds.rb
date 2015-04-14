
puts "ADDING GENRES TO DB:"
ifile = './generes_by_popularity.csv'
File.open(ifile).readlines.each do |line|
  name, popularity, g1, g2, g3 = line.chomp.split(",")
  Genre.find_or_create_by(name: name,
                          popularity: popularity,
                          group: "#{g1}" + "#{g2}" + "#{g3}")
  print "+"
end



