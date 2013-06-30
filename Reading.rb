require 'Stack'
require 'Hook'
require 'Recording'
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
		@recordings = {}
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
			
			#read_block = @hook_stack.empty? or @hook_stack.top.step(@memory, b)
			updateRecordings(b)
			unless metaData == nil
				
				tail = metaData.gsub(/\\\"/,'"')

				if @hook_stack.empty? or @hook_stack.top.step(@memory, b)
					str = sprintf( "%s%s",b.sub(tail,''),evaluateCommand(getCommand(metaData)))
					if @format["saveMetadata"]
						yield str+metaData
					else
						yield str
					end
				else
					yield ""
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
	
	def updateRecordings(block)
		#@recordings.each{|i| p i}
		@recordings.each_value{|i| i.add block }
		#@recordings.each{|i| p i}
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
		@recordings.each_value{|rec| rec.stopIfOverAt! name }
		@hook_stack.pop.trigger(@memory) if @hook_stack.top!=nil and @hook_stack.top.match?(name)
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

=begin	
	##
	#	calls set with the correct paramaters
	#
	def setAtIndex(name, index, assignment_proc)
		#p "set with index"+assignment_proc
		@memory[name][index] = assignment_proc.call(@memory)
		return "" 
	end
=end
	
	##
	#	calls set with the correct paramaters
	#
	def set(name, assignment_proc)
		eval("def set_proc(m)"+assignment_proc+"; end")	
		@memory[name] = set_proc(@memory)
		return ""
	end	
	
=begin
	##
	#	calls get with the correct paramaters including index
	#
	def getAtIndex(name, index, prefix, suffix)
		return "<<Error: Name not found in memory>>" unless @memory.has_key? name
		return "<<Error: Name has no index>>" unless @memory.has_key? name
		return prefix + @memory[name][index] + suffix unless @memory[name][index].nil?
		return "" 
	end	
=end
	
	
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
		@recordings[name] = Recording.new(end_label)
		#@recordings.push(name)
		return ""
	end
	
	##
	#	calls play with the correct paramaters
	#
	def play(name)
		playback = ""
		#p name
		#p @recordings[name]
		processBlocks(@recordings[name].play){|r| playback<<r }
		return playback
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
			
=begin
			test_format = getFormats["test"]
			read = Reading.new(test_format)	
			test = ""
			read.readTemplate "aa<{\"type\":\"set\",\"name\":\"test\",\"function\":\"return 'cc'\"}>STOP<{\"type\":\"get\",\"name\":\"test\", \"index\":0, \"prefix\":\"<\", \"suffix\":\">\"}>STOPbb", test					
			assert_equal "aabb", test, "TEST GET assigned without index"
=end					
		end
		
		#get valid variable test
		def test_getting_valid_variable
			test_format = getFormats["test"]
			read = Reading.new(test_format)		
			test = ""
			read.readTemplate "aa<{\"type\":\"set\",\"name\":\"test\",\"function\":\"return 'cc'\"}>STOP<{\"type\":\"get\",\"name\":\"test\",\"prefix\":\"<\", \"suffix\":\">\"}>STOPbb", test
			assert_equal "aa<cc>bb", test, "TEST GET ASSIGNED"
			assert_equal "cc", read.memory["test"], "Failure to store variable"
			
=begin
			read = Reading.new(test_format)		
			test = ""
			read.readTemplate "aa<{\"type\":\"set\",\"name\":\"test\", \"index\":0,\"function\":\"return 'cc'\"}>STOP<{\"type\":\"get\",\"name\":\"test\", \"index\":0,\"prefix\":\"<\", \"suffix\":\">\"}>STOPbb", test
			assert_equal "aa<cc>bb", test, "TEST GET ASSIGNED with index"
			assert_equal "cc", read.memory["test"], "Failure to store variable"	
=end
							
		end
		
		#test record and play
		def test_record_and_play_once
			test_format = getFormats["test"]
			read = Reading.new(test_format)		
			test = ""
			read.readTemplate "aa<{\"type\":\"record\",\"name\":\"test\",\"end_label\":\"end\"}>STOPcSTOPdSTOP<{\"type\":\"label\",\"name\":\"end\"}>STOP<{\"type\":\"play\",\"name\":\"test\"}>STOPbb", test
			assert_equal "aacdcdbb", test, "test record and play once"
			#assert_equal "c", read.memory["test"], "Failure to store variable"	
		end
		
=begin	
		#test record and play
		def test_record_and_play_empty_record
			test_format = getFormats["test"]
			read = Reading.new(test_format)		
			test = ""
			read.readTemplate "aa<{\"type\":\"record\",\"name\":\"test\",\"end_label\":\"end\"}>STOP<{\"type\":\"label\",\"name\":\"end\"}>STOP<{\"type\":\"play\",\"name\":\"test\"}>bb", test
			assert_equal "aabb", test, "test record and play empty"
			#assert_equal "c", read.memory["test"], "Failure to store variable"	
		end	
		
		#test record with no end
		def test_record_no_termination
			test_format = getFormats["test"]
			read = Reading.new(test_format)		
			test = ""
			read.readTemplate "aa<{\"type\":\"record\",\"name\":\"test\",\"end_label\":\"end\"}>STOPcSTOPbb", test
			assert_equal "aacbb", test, "test record and play empty"
			assert_equal ["c","bb"], read.memory["test"], "Failure to record blocks"	
		end	
=end						
	end

	def test_array_sims
		test_format = getFormats["test"]
		read = Reading.new(test_format)		
		test = ""	
		read.readTemplate "aa<{\"type\":\"set\",\"name\":\"array\",\"function\":\"return ['cc','dd']\"}>STOP<{\"type\":\"set\",\"name\":\"var\",\"function\":\"return m['array'][0]\"}>STOP<{\"type\":\"get\",\"name\":\"var\"}>STOP<{\"type\":\"set\",\"name\":\"var\",\"function\":\"return m['array'][1]\"}>STOP<{\"type\":\"get\",\"name\":\"var\"}>STOPbb", test
		assert_equal "aaccddbb", test, "didn't handle array properly"
		assert_equal "dd", read.memory["var"], "var not pointed correctly"		
	end
	#Test_Reader.new.test
	#test.test
end

