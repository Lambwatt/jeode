require 'Stack'
require 'Hook'
require 'test/unit'

require 'rubygems'
require 'json'

run_tests = true

$prompt = ">>" unless defined? $prompt
	

		
##
#	Handles a reading of a given template
#
class Reading
	
	attr_reader :memory, :hook_stack
	
	def valid_json? com
	 	return JSON.parse(com)   
	rescue JSON::ParserError 
	 	return nil 
	end 	
	
	##
	#	Ininitalizes memory with a blank if no hash is given
	#
	def initialize(format, mem={})
		@memory = mem.clone
		@format = format
		@hook_stack = Stack.new
	end
	
	##
	#	Read a template
	#
	def readTemplate(template, destination_file)
		return "" unless template.is_a? ::String
		processBlocks(template.split(/STOP/)){|r| destination_file<<r}
	end
	
	##
	#	Processes the array of blocks given to it
	#	
	def processBlocks(blocks)
		return [""] unless blocks.is_a? ::Array and not blocks.empty?
		
		blocks.each{ |b|
			
			tail = ''
			metaData = getMetaData(b)
			
			unless metaData == nil
				
				tail = metaData.gsub(/\\\"/,'"')

				str = sprintf( "%s%s",b.sub(tail,''),evaluateCommand(getCommand(metaData)))
				if @hook_stack.empty? or not @hook_stack.top.step(@memory, b)
					if @format["saveMetadata"]
						yield str+metaData
					else
						yield str
					end
				else
					if @format["saveMetadata"]
						p "took 3"
						yield b
					else
						p "took 4"
						yield b.sub(tail,'')
					end
				end					
			else
				yield b
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
		elsif (@format["format"] == "html")
			metaData = block.gsub(/["]/,'\\\"').match(/#{commentStart}(.*[\s]*.*)*#{commentEnd}/) 
		else
			metaData = metaData.match(/#{commentStart}(.*[\s]*.*)*#{commentEnd}/) 
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
		
		return JSON.parse(com)  if valid_json? com 
		return nil 			
	end
	
###############################################################################
#	Evaluation for base commands
	
	##
	#	figures out which command to run
	#
	def evaluateCommand(com)
		return if com.nil?

		case com["type"]
		when "label"
			return runLabel(com)
		when "get"			
			return runGet(com)
		when "request"
			return runRequest(com)
		when "set"
			return  runSet(com)
		when "record"
			return runRecord(com)
		when "play"
			return runPlay(com)
		when "switch"
			return runSwitch(com)
		else
			#p "took else"
			return evaluateComplexCommand(com)
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
		#ADD INDEX SUPPORT AT A LATER TIME
		#if(com.has_key? "index")
		#	return set(	com["name"],
		#				com["function"]
		#						  )			
		#else
			return set(	com["name"],
						com["function"]
			          )
		#end
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
	#	calls switch with the correct paramaters
	#
	def runSwitch(com)
		return switch(	com["test_function"],
						com["result_label_hash"]
		             )	
	end	
	
#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
#	Actual commands
	
	##
	#	handles a label
	#
	def label(name)
		@hook_stack.pop.trigger(@memory) if @hook_stack.top!=nil and @hook_stack.top.mach?(name)
		return ""
	end
	
	##
	#	requests input form the user
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
		return "" 		
	end
	
	##
	#	calls set with the correct paramaters
	#
	#def set(name, index, assignment_proc)
	#	p "set with index"+assignment_proc
#		@memory[name][index] = assignment_proc.call(@memory)
	#	return "" 
	#end
	
	##
	#	calls set with the correct paramaters
	#
	def set(name, assignment_proc)
		eval("def set_proc(m)"+assignment_proc+"; end")	
		@memory[name] = set_proc(@memory)
		return ""
	end	
	
	##
	#	calls get with the correct paramaters
	#
	def get(name, prefix, suffix)
		
		return prefix + @memory[name]+suffix unless @memory[name].nil?
		return "" 
	end
	
	##
	#	calls record with the correct paramaters
	#
	def record(name, end_label)
		@hook_stack.push(	Hook.new(end_label, 
							proc{},
		            		proc{|mem,block| mem[name]<<block; return true}))
		return ""
	end
	
	##
	#	calls play with the correct paramaters
	#
	def play(name)
		processBlocks(@memory[name])
		return ""
	end
	
	##
	#	calls label with the correct paramaters
	#
	def switch(test, end_labels)
		@hook_stack.push(Hook.new(end_labels[test.call(@memory)], proc{}, proc{return false}))
		return ""	
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
	require 'TemplateFormats'
	class Test_Reader<Test::Unit::TestCase
		

		#empty cases
		def test_nil_input
			test_format = getFormats["test"]
			read = Reading.new(test_format)
			test = ""
			read.readTemplate nil, test
			assert_equal("", test, "Did not handle nil")
		end
		
		def test_no_stops_in_input
			test_format = getFormats["test"]
			read = Reading.new(test_format)	
			test = ""
			read.readTemplate "aabb", test				
			assert_equal "aabb", test, "Did not handle no stops"
		end
		
		def test_multiple_blocks
			test_format = getFormats["test"]
			read = Reading.new(test_format)
			test = ""
			read.readTemplate "aaSTOPbb", test			
			assert_equal "aabb", test, "Did not handle multiple blocks with no stops"
		end
		
		def test_empty_instruction
			test_format = getFormats["test"]
			read = Reading.new(test_format)
			test = ""
			read.readTemplate "aa<>STOPbb", test	
			assert_equal "aabb", test, "Did not handle empty instruction"
		end
		
		#unrecognized function
		def test_non_existant_function
			test_format = getFormats["test"]
			read = Reading.new(test_format)
			test = ""
			read.readTemplate "aa<{\"type\":\"bogus\"}>STOPbb", test			
			assert_equal "aabb", test, "Did not handle bad instruction"
		end
		
		#label cases
		def test_label
			test_format = getFormats["test"]
			read = Reading.new(test_format)	
			test = ""
			read.readTemplate "aa<{\"type\":\"label\",\"name\":\"test\"}>STOPbb", test		
			assert_equal "aabb", test, "did not handle label"
		end


		#set variable tests
		def test_setting_variable
			test_format = getFormats["test"]
			read = Reading.new(test_format)		
			test = ""
			read.readTemplate "aa<{\"type\":\"set\",\"name\":\"test\",\"function\":\"return 'cc'\"}>STOPbb", test				
			assert_equal "aabb", test, "mistake in processing variable assignment"
			assert_equal "cc", read.memory["test"], "Failure to store variable"
			
			test_format = getFormats["test"]
			read = Reading.new(test_format)		
			test = ""
			read.readTemplate "aa<{\"type\":\"set\",\"name\":\"test\",\"function\":\"return 'cc'\"}>STOP<{\"type\":\"get\",\"name\":\"test\",\"prefix\":\"<\", \"suffix\":\">\"}>STOPbb", test				
			assert_equal "aa<cc>bb", test, "mistake in processing variable assignment"
			assert_equal "cc", read.memory["test"], "Failure to store variable"	
			assert_equal "cc", read.memory["test"], "Failure to store variable"			
		end
			
			#assert_equal read.processBlocks(["aa<\"type\":\"set\",\"name\":\"test\",\"index\":\"0\"\"function\":\"return \"cc\"\">","bb"]).each, ["aa","bb"], "mistake in processing variable assignment with index"
			#assert_equal read.memory["test"][0], "cc", "Failure to store variable with index"
			
		#get bad variable test
		def test_getting_invalid_variable
			test_format = getFormats["test"]
			read = Reading.new(test_format)	
			test = ""
			read.readTemplate "aa<{\"type\":\"get\",\"name\":\"testing\", \"prefix\":\"<\", \"suffix\":\">\"}>STOPbb", test					
			assert_equal "aabb", test, "TEST GET UNASSIGNED"		
		end
		
		#get valid variable test
		def test_getting_valid_variable
			test_format = getFormats["test"]
			read = Reading.new(test_format)		
			test = ""
			read.readTemplate "aa<{\"type\":\"set\",\"name\":\"test\",\"function\":\"return 'cc'\"}>STOP<{\"type\":\"get\",\"name\":\"test\",\"prefix\":\"<\", \"suffix\":\">\"}>STOPbb", test
			assert_equal "aa<cc>bb", test, "TEST GET ASSIGNED"
			assert_equal "cc", read.memory["test"], "Failure to store variable"	
			#assert_equal read.processBlocks(["aa<\"type\":\"get\",\"name\":\"test\", \"prefix\":\"<\", \"suffix\":\">\" >","bb"]).each, ["aa<cc>", "bb"], "TEST GET ASSIGNED with valid index"
			#assert_equal read.processBlocks(["aa<\"type\":\"get\",\"name\":\"test\", \"prefix\":\"<\", \"suffix\":\">\" >","bb"]).each, ["aa", "bb"], "TEST GET ASSIGNED invalid index"
		end
		
			#test record
			#assert_equal read.processBlocks(["aa<\"type\":\"record\",\"name\":\"test_rec\, \"name\":\"test_rec\">","bb"]).each, ["aa","bb"], "TEST recording over no space"
			
			#assert_equal read.processBlocks(["aa<\"type\":\"label\",\"name\":\"test\">","bb"]).each, ["aa","bb"], "TEST un-ending recording"
			
			#assert_equal read.processBlocks(["aa<\"type\":\"label\",\"name\":\"test\">","bb"]).each, ["aa","bb"], "one block recording recording"
	end
	
	#Test_Reader.new.test
	#test.test
end


