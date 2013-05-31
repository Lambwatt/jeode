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
	@prompt = ">>"
	@path = ""
	@formats = getFormats
	
	def evalParamater(guide)
		eval(guide["validate"])	
						
		p guide["prompt"]
		puts @prompt
	
		s = gets
		until (validate(s))
			s = gets
		end
		
		s.gsub!(/[\n\t]/,'')	
			
		return '#{guide["prefix"]}#{s}#{guide[suffix]}'
	end
	
	def evalVariable(guide)	
			return '#{guide["prefix"]}#{memory[guide["name"]]}#{guide[suffix]}'
		end	
	
	def evalGuide(guide, memory)
		case guide["type"]
		when "paramater"
			return evalParamater(guide)
		when "variable"
			return evalVariable(guide, memory)
		end
	end
	
	def fillTemplate(templateFile, destFile, format)
		
		unless @formats.hasKey? format
			p "format not recognized"
			return
		end
		
		commentStart = @formats[format]["commentStart"]
		commentEnd = @formats[format]["commentEnd"]
		
		memory = {"name"=> @name}
		
		append_file_sandwhich(destFile){|dest|
			read_file_sandwhich(templateFile){|js_file|
				
				js_file.read.split(/STOP/).each{ |section|
					
					metaData = section.gsub(/["]/,'\\\"').match(/#{commentStart}(.[\s]*.)*#{commentEnd}/)
					
					unless metaData == nil
						metaData = metaData[0]
						guide = metaData.gsub(/[\n\t\\]/,'')
						guide = guide[2...-2]
						guide = JSON.parse(guide)
				
						tail = metaData.gsub(/\\\"/,'"')
						
						destFile<<section.sub(tail,'')
						destFile<<metaData
						destFile<<evalGuide(guide, memory)
					else
						destFile<<section
					end
				}
			}
		}
	end
	
	def createGameCode()
		
		fillTemplate("statics.js","#{@path}/#{@name}.js","javascript")
		fillTemplate("intervals.js","#{@path}/#{@name}.js", "javascript")
		fillTemplate("controls.js","#{@path}/#{@name}.js", "javascript")
	end
	
	def createToolsCode
		#create tool list
		#print tool list
		#ask for tools to add
		#create tools code
	end
	
	def createGameCanvas()
		
		fillTemplate("canvas.html","#{@path}/#{@name}.html","html")
		
=begin
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
		
=end
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
	
	def setGameName
		@name = "testGame"
	end
	
	def createGame
		path = setGamePath
		name = setGameName
		createGameCanvas()
		createGameCode()	
			
	end
	
end