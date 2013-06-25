class Stack
	
	def initialize
		@contents = []
	end
	
	def push(input)
		@contents.push(input)
	end
	
	def pop
		return @contents.pop
	end
	
	def top
		return @contents[-1]
	end
	
	def empty?
		return @contents.empty?
	end
end