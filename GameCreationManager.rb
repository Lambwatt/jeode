require 'rubygems'
require 'json'

def read_file_sandwhich(fileName)
	file = open(filename, 'r')
	yield(file)
	ensure
		file.close if file
end

def append_file_sandwhich(fileName)
	file = open(filename, 'a')
	yield(file)
	ensure
		file.close if file
end

class GameCreationManager
	prompt = ">>"
	path = ""
	
	def fillJsTemplate(templateName, destFile)
		js_file = open(templateName, 'r')
		#output = open("test.js",'w')
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
				destFile<<section.sub(tail,'')
				destFile<<param
				destFile<<"\"#{s}\""
			else
				destFile<<section
			end
		}
		js_file.close		
	end
	
	def createGameCode
		
		#get loop interval
		puts "Specify loop interval"
		drawInterval = 30
		puts "[0]default(#{loopInterval}) [1]custom"
		puts prompt
		
		x = gets
		if (x == 1)
			begin
				puts "enter loop interval in milliseconds (integer)"
				puts prompt
				x = gets.to_i
			end while(x<=0)
			loopInterval = x
		end
		
		#add draw interval
		

		#get update interval
		puts "Specify update interval"
		updateInterval = 10
		puts "[0]default (#{updateInterval}) [1]custom"
		puts prompt
		
		x = gets
		if (x == 1)
			begin
				puts "enter update interval in milliseconds (integer)"
				puts prompt
				x = gets.to_i
			end while(x<=0)
			drawInterval = x
		end		
		#add update interval

	
=begin	
		#get apply physics
		begin
			puts "add physics? (y/n)"
			puts prompt
			x = gets.to_i
		end while(x!='y' and x!='n')
				
		if(x=='y')
			begin
				puts "apply to all? (y/n)"
				puts prompt
				x = gets.to_i
			end while(x!='y' and x!='n')
			
			appToAll = x
			
			#gameObjects.each{|n|
				#add code for top of object up to begining of update
				#if y, update will include physics
					
				#else
					#ask
					#if y, update will include physics				
				#}
			
		end	
=end

		#get keyboard and mouse watches
		#get background color
	end
	
	def createToolsCode
		#create tool list
		#print tool list
		#ask for tools to add
		#create tools code
	end
	
	def createGameCanvas(path)
		
		#so sketchy.  must find a better way to handle this
		name = 2;
		width = 0;
		height = 1;
		
		params = []
		
		#get name
		puts "name of game\n"
		puts prompt
		x = gets
		
		x.sub(/[ \t\n]/, '_')
		params[name] = x
		
		#get width
		puts "specify width (integer > 0)\n"
		puts prompt
		x = gets
		
		until(x.to_i>0)
			puts "specify width (integer > 0)\n"
			puts prompt			
			x = gets
		end
		params[width] = x
						
		#get height
		puts "specify height (integer > 0)\n"
		puts prompt
		x = gets
		
		until(x.to_i>0)
			puts "specify height (integer > 0)\n"
			puts prompt			
			x = gets
		end
		params[hight] = x				
		
		
		#create page
		
		
	end
	
	def pathValid?(path)
		return true
	end
	
	def setGamePath
		inputPath = ""
		puts "Specify path\n"
		puts prompt
		
		inputPath = gets
		until(pathValid(inputPath))
		end	
		return inputPath		
	end
	
	def createGame
		path = setGamePath
		createGameCanvas(path)
		#createGameCode	
			
	end
	
end