#from: http://static.echonest.com/popcorn/
require 'pry'
ifile = './genres_raw.html'
ofile = File.open('./generes_by_popularity.csv', "w")

File.open(ifile).readlines.each do |line|
  id, size = line.split('" ').map {|x| x if x.include?("id=") || x.include?("r=") }.compact
  id = id.split("=")[1].gsub(/"/,"")
  size = size.split("circle r=")[1].gsub(/"/,"")
  puts "ID:#{id} SIZE: #{size}"
  ofile.puts "#{id},#{size}"
end

ofile.close
