require 'TemplateFormats'
require 'tools'
require 'Reading'

require 'rubygems'
require 'json'

def initializeFile(name)
	file = open(name, 'w')
	file.close
end

def read_file_sandwhich(fileName)
	file = open(fileName, 'r')
	yield(file)
	ensure
		file.close if file
end

def append_file_sandwhich(fileName)
	file = File.open(fileName, 'a')
	yield(file)
	ensure
		file.close if file
end

class GameCreationManager
	
	def initialize
		@prompt = ">>"
		@path = "outputs"
		@formats = getFormats
	end
	
	def fillTemplate(templateFile, destFile, format)
			
			
			unless @formats.has_key? format
				p "format not recognized"
				return
			end
			
			append_file_sandwhich(destFile){|dest|
				read_file_sandwhich(templateFile){|js_file|
					
					template_reading = Reading.new(@formats[format], {"name"=> @name2})
					
					template_reading.readTemplate(js_file.read,dest)
				}
			}
		end	
	
	def createGameCode()	
		fillTemplate("jsTemplates/statics.js","#{@path}/#{@name}.js","javascript")
		fillTemplate("jsTemplates/intervals.js","#{@path}/#{@name}.js", "javascript")
		fillTemplate("jsTemplates/controls.js","#{@path}/#{@name}.js", "javascript")		
	end
	
	def createToolsCode
		#create tool list
		#print tool list
		#ask for tools to add
		#create tools code
	end
	
	def createGameCanvas()	
		fillTemplate("htmlTemplates/canvas.html","#{@path}/#{@name}.html","html")		
	end
	
	def pathValid?(path)
		return true
	end
	
	def setGamePath
		inputPath = ""
		puts "Specify path\n"
		puts @prompt
		
		inputPath = gets
		until(pathValid?(inputPath))
		end	
		@path = inputPath.chomp("\n")		
	end
	
	def setGameName
		@name = "testGame"
	end
	
	def createGame
		setGameName
		
		initializeFile("#{@path}/#{@name}.html")
		createGameCanvas
		
		initializeFile("#{@path}/#{@name}.js")
		createGameCode	
	end
	
	
	
end