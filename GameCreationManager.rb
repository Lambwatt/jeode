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
	
	def evalParamater(guide)
		eval(guide["validate"])	
						
		p guide["prompt"]
		puts @prompt
	
		s = gets
		until (validate(s))
			s = gets
		end
		
		s.gsub!(/[\n\t]/,'')	
			
		pre = guide["prefix"]
		suf = guide["suffix"]
		return pre+s+suf
	end
	
	def evalVariable(guide, memory)	
		str1 = guide["prefix"]
		str2 = memory[guide["name"]]
		str3 = guide["suffix"]
		return str1+str2+str3
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
		
		unless @formats.has_key? format
			p "format not recognized"
			return
		end
		
		commentStart = @formats[format]["commentStart"]
		commentEnd = @formats[format]["commentEnd"]
		
		memory = {"name"=> @name}
		
		append_file_sandwhich(destFile){|dest|
			read_file_sandwhich(templateFile){|js_file|
				
				js_file.read.split(/STOP/).each{ |section|
					
					#nFix redundant operations
					metaData = section.gsub(/["]/,'\\\"').gsub(/[\n\t]/,'')
					metaData = metaData.match(/#{commentStart}(.[\s]*.)*#{commentEnd}/) if format == "javascript"
					metaData = section.gsub(/["]/,'\\\"').match(/#{commentStart}(.[\s]*.)*#{commentEnd}/) if format == "html"
					
					unless metaData == nil
						metaData = metaData[0]
						guide = metaData.gsub(/[\n\t]/,'')
						guide.gsub!(/\\\"/,"\"")
						guide = guide[ @formats[format]["startLength"]...-(@formats[format]["endLength"])]
						guide = JSON.parse(guide)
				
						tail = metaData.gsub(/\\\"/,'"')
						
						str = sprintf( "%s%s",section.sub(tail,''),evalGuide(guide, memory))
						dest<<str
					else
						dest<<section
					end
				}
			}
		}
	end
	
	def fillTemplate2(templateFile, destFile, format)
			
			
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
		#fillTemplate("jsTemplates/statics.js","#{@path}/#{@name}.js","javascript")
		#fillTemplate("jsTemplates/intervals.js","#{@path}/#{@name}.js", "javascript")
		#fillTemplate("jsTemplates/controls.js","#{@path}/#{@name}.js", "javascript")
		
		#fillTemplate("jsTemplates/statics.js","#{@path}/#{@name}.js","javascript")
		fillTemplate2("jsTemplates/intervals2.js","#{@path}/#{@name2}.js", "javascript")
		#fillTemplate("jsTemplates/controls2.js","#{@path}/#{@name}.js", "javascript")		
	end
	
	def createToolsCode
		#create tool list
		#print tool list
		#ask for tools to add
		#create tools code
	end
	
	def createGameCanvas()	
		#p "path 1 = #{@path}/#{@name}.html"
		#fillTemplate("htmlTemplates/canvas2.html","#{@path}/#{@name}.html","html")
		
		p "path 2 = #{@path}/#{@name2}.html"
		fillTemplate2("htmlTemplates/canvas2.html","#{@path}/#{@name2}.html","html")		
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
		#@name = "testGame"
		@name2 = "testGame2"
	end
	
	def createGame
		setGameName
		
		initializeFile("#{@path}/#{@name}.html")
		createGameCanvas
		
		initializeFile("#{@path}/#{@name}.js")
		createGameCode	
	end
	
	
	
end