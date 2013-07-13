class Hook
	#attr_reader :label
	
	def initialize(label, trigger_response_proc_taking_mem, step_response_proc_taking_mem_and_block=proc{} )
		@label = label
		@trigger_response = trigger_response_proc_taking_mem #must be a proc expecting a block (mem)
		@step_response = step_response_proc_taking_mem_and_block #must be a proc expecting 2 blocks (mem, block)
	end
	
	def match?(label)
		return true if @label==label
		return false
	end

	def trigger(mem)
		return @trigger_response.call(mem)
	end	
	
	def step(mem, block)
		return @step_response.call(mem, block)
	end	
end