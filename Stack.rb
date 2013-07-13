require 'test/unit'

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

class Test_Reader<Test::Unit::TestCase
	
	def test_emptyness
		stack = Stack.new
		assert_equal stack.empty?, true, "empty stack does not appear empty"
		
		stack.push("test")
		assert_equal stack.empty?, false, "stack of one reads as empty"
	end
	
	def test_add_and_remove
		stack = Stack.new
		stack.push("test")
		
		assert_equal stack.top, "test", "object not added to stack"
		
		stack.pop
		assert_equal stack.empty?, true, "stack is not empty after removal"
		
		assert_equal stack.top, nil, "poping only item did not leave nil on the stack"
	end
end
