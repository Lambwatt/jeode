require 'rubygems'
require 'json'

js_file = open("testTemplate.js", 'r')
output = open("test.js",'w')
js_file.read.split(/PARAM/).each{ |section|
	param = section.gsub(/["]/,'\\\"').match(/\/\*(.[\s]*.)*\*\//)
	unless param == nil
		p param
		param = param[0]
		guide = param.gsub(/[\n\t\\]/,'')
		guide = guide[2...-2]
		guide = JSON.parse(guide)

		eval(guide["validate"])	

		p guide["prompt"]
		puts ">>"
	
		s = gets
		until (validate(s))
			s = gets
		end
		
		s.gsub!(/[\n\t]/,'')

		tail = param.gsub(/\\\"/,'"')
		p tail
		p section
		output<<section.sub(tail,'')
		output<<param
		output<<"\"#{s}\""
	else
		output.puts section
	end
}
output.close
js_file.close

