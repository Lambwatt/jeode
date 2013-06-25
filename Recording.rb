class Recording
	
	def initialize(end_label)
		@end_label = end_label
		@contents = []
		@active = true
	end

	def add(block)
		@contents<<block if @active
	end
	
	def play()
		return @contents
	end
	
	def stopIfOverAt!(label)
		@active = false if @end_label==label 
	end
end