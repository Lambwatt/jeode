require 'rubygems'
require 'json'

js_file = open("testTemplate.js", 'r')
output = open("test.js",'w')
js_file.read.split(/PARAM/).each{ |section|
	param = section.gsub(/["]/,'\\\"').gsub(/[\n\t\\]/,'').match(/\/\*(.[\s]*.)*\*\//)
	unless param == nil
		p param
		param = param[0]
		param = param[2...-2]
		param = JSON.parse(param)

		eval(param["validate"])	

		p param["prompt"]
		puts ">>"
	
		s = gets
		until (validate(s))
			s = gets
		end
		
		s.gsub!(/[\n]/,'')

		output<<section
        	output<<"\"#{s}\""
	else
		output.puts section
	end
}
output.close
js_file.close

