run_tests = true

$prompt = ">>" unless defined? $prompt
	
##
#	Handles a reading of a given template
#
class Reading
	
	##
	#	Ininitalizes memory with a blank
	#
	def initialize(format)
		@memory = {}
		@format = format
	end	
	
	##
	#	Ininitalizes memory with the value of mem_hash
	#	
	def initialize(format, mem)
		@memory = mem.clone
		@format = format
	end
	
	##
	#	Read a template
	#
	def readTemplate(template, destination_file)
		
		@dest = destination_file
		processBlocks(template.split(/STOP/))
	end
	
	##
	#	Processes the array of blocks given to it
	#	
	def processBlocks(blocks)
		return unless defined? @dest
			
		blocks.each{ |b|
			
			tail = ''
			metaData = getMetaData(b)

			unless metaData == nil
				
				tail = metaData.gsub(/\\\"/,'"')
				
				str = sprintf( "%s%s",b.sub(tail,''),evaluateCommand(getCommand(metaData)))
				@dest<<str
			else
				@dest<<b
			end
			
			
		}
	end
	
	##
	#	seperates metadata from a block string
	#
	def getMetaData(block)
		
		commentStart = @format["commentStart"]
		commentEnd = @format["commentEnd"]		
		
		#FixMe redundant operations and handle formats better
		metaData = block.gsub(/["]/,'\\\"').gsub(/[\n\t]/,'')
		if (@format["format"] == "javascript")
			metaData = metaData.match(/#{commentStart}(.[\s]*.)*#{commentEnd}/) 
		end
		
		if (@format["format"] == "html")
			metaData = block.gsub(/["]/,'\\\"').match(/#{commentStart}(.*[\s]*.*)*#{commentEnd}/) 
		end		
	
		unless metaData == nil
				metaData = metaData[0]
		end
						
		return metaData
	end
	
	##
	#	Get Command from metaData
	#
	def getCommand(metaData)
		com = metaData.gsub(/[\n\t]/,'')
		com.gsub!(/\\\"/,"\"")
		com = com[ @format["startLength"]...-(@format["endLength"])]	
		
		return JSON.parse(com)	
	end
	
###############################################################################
#	Evaluation for base commands
	
	##
	#	figures out which command to run
	#
	def evaluateCommand(com)
		
		#p com["type"]
		
		case com["type"]
		when "label"
			return runLabel(com)
		when "get"
			return runGet(com)
		when "request"
			return runRequest(com)
		when "set"
			return runSet(com)
		when "record"
			return runRecord(com)
		when "play"
			return runPlay(com)
		when "switch"
			return runSwitch(com)
		else
			p "took else"
			evaluateComplexCommand(com)
		end
	end

#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
#	Assign command variables to correct paramaters for commands
		
	##
	#	calls label with the correct paramaters
	#
	def runLabel(com)
		return label(com["name"])
	end
	
	##
	#	calls request with the correct paramaters
	#
	def runRequest(com)
		
		return request(	com["name"],
						com["prompt"], 
						com["validation_function"], 
						com["processing_function"]
		              )
	end
	
	##
	#	calls set with the correct paramaters
	#
	def runSet(com)
		return set(	com["name"],
					com["function"]
		          )
	end
	
	##
	#	calls get with the correct paramaters
	#
	def runGet(com)
		return get(	com["name"],
					com["prefix"],
					com["suffix"]
		          )
	end
	
	##
	#	calls record with the correct paramaters
	#
	def runRecord(com)
		return record(	com["name"],
						com["end_label"]
		             )
	end
	
	##
	#	calls play with the correct paramaters
	#
	def runPlay(com)
		return play(com["name"])
	end
	
	##
	#	calls label with the correct paramaters
	#
	def runSwitch(com)
		return switch(	com["test_function"],
						com["result_label_hash"]
		             )	
	end	
	
#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
#	Actual commands
	
	##
	#	calls label with the correct paramaters
	#
	def label(name)
		return 
	end
	
	##
	#	calls request with the correct paramaters
	#
	def request(name, prompt, validation, process)
		
		eval("def validate(s)"+validation+"; end")	
		
		p prompt
		puts $prompt
							
		s = gets
		until (validate(s))
			p "error please re-enter paramater"
			p prompt
			puts $prompt
			
			s = gets
		end
		
		s.gsub!(/[\n\t]/,'')	
			
		@memory[name] = s
		return 		
	end
	
	##
	#	calls set with the correct paramaters
	#
	def set(com)
		return 
	end
	
	##
	#	calls get with the correct paramaters
	#
	def get(name, prefix, suffix)
		
		p "ran get for "+name
		
		str1 = prefix
		str2 = @memory[name]
		str3 = suffix
		return str1+str2+str3
	end
	
	##
	#	calls record with the correct paramaters
	#
	def record(com)
		return 
	end
	
	##
	#	calls play with the correct paramaters
	#
	def play(com)
		return 
	end
	
	##
	#	calls label with the correct paramaters
	#
	def switch(com)

		return 		
	end		
	
###############################################################################
#	Evaluation for complex commands (1 or more basde commands)
	
	##
	#	Evaluate a command made from the base commands above
	#
	def evaluateComplexCommand(com)
		return ""
	end
		
	
end

if run_tests

	commentStart ="<!--"
	commentEnd = "-->"

	testString = " <!--{\"type\":\"get\",\"name\":\"width\",\"prefix\":\"width=\\\"\",\"suffix\":\"px\\\"\"}-->"
	p testString.gsub(/["]/,'\\\"')
	p testString.gsub(/["]/,'\\\"').match(/#{commentStart}(.*[\s]*.*)*#{commentEnd}/)
 
end
