# Open files for I/O
raw_name = "complex.txt"
pro_name = "complexPARSED.txt"

raw_file = File.open(raw_name, "r")
pro_file = File.open(pro_name, "w")

xodump = "0.000000"
yodump = "0.000000"

xdump = "0.000000"
zdump = "0.000000"
ydump = "0.000000"

pro_file.puts "----"

while !raw_file.eof?
	contents = raw_file.readline
	#puts contents
	
	# Check for new Packet
	if contents.match("Field: 1, m_nTick\.")
		pro_file.puts "x: " + xdump
		pro_file.puts "y: " + ydump
		pro_file.puts "z: " + zdump
		pro_file.puts "xO: " + xodump
		pro_file.puts "yO: " + yodump
		pro_file.puts "----"
	
	
	# vecOrigin
	elsif contents.match("Field: 2, m_vec\.")
		temp = ""
		temp << contents[24..-1].to_s
		temparray = temp.split(/[,] /)
		xodump = temparray[0].to_s
		yodump = temparray[1].to_s
	
	
	# vecVelocity
	elsif contents.match("Field: 4, m_vec\.")
		xdump = contents[29..-1].to_s
		xdump = "0.000000" if xdump.length == 0
	

	elsif contents.match("Field: 5, m_vec\.")
		ydump = contents[29..-1].to_s 
		ydump = "0.000000" if ydump.length == 0
	

	elsif contents.match("Field: 6, m_vec\.")
		zdump = contents[29..-1].to_s
		zdump = "0.000000" if zdump.length == 0
	
	
	else
	  #puts "nothing"
	end
	
end

raw_file.close
pro_file.close