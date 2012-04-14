
read_file = File.new(ARGV[0], "r")
write_file = File.new("#{ARGV[0]}.chopped", "w")

while (line = read_file.gets)
  num = line.to_f
  write_file.puts("%0.6f" % num)
end

read_file.close
write_file.close

