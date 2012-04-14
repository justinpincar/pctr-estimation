
read_file = File.new(ARGV[1], "r")
write_file = File.new("#{ARGV[1]}.#{ARGV[0]}", "w")

count = 0
while ((line = read_file.gets) && (count < ARGV[0].to_i))
  write_file.puts(line)
  count += 1
end

read_file.close
write_file.close

