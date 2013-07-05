ARGV.each do |fn|
  puts "Loading #{fn} ..."
  load fn
end
