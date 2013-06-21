def lengthWithEscapes(string)
	i = 0
	string.split(/\./){|m|
		i+=1
	}
	return string.length-i
end
	
=begin
p lengthWithEscapes("aaa")==3
p lengthWithEscapes("a\aa")==3
p lengthWithEscapes("\\")==1
p lengthWithEscapes("")==0
p lengthWithEscapes("\/\*")==2
p lengthWithEscapes("\*\/")==2
=end