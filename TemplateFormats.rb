def getFormats
	formats = {}

	formats["javascript"] = {"format"=>"javascript","commentStart"=>"\\\/\\\*", "commentEnd"=>"\\\*\\\/", "startLength"=>2, "endLength"=>2, "saveMetadata"=>true}
	formats["html"] = {"format"=>"html","commentStart"=>"<!--", "commentEnd"=>"-->", "startLength"=>4, "endLength"=>3, "saveMetadata"=>false}
	formats["test"] = {"format"=>"test","commentStart"=>"<", "commentEnd"=>">", "startLength"=>1, "endLength"=>1, "saveMetadata"=>false}
	return formats
end


=begin
formats = getFormats
commentStart = formats["javascript"]["commentStart"]
commentEnd = formats["javascript"]["commentEnd"]

p commentStart
p commentEnd



commentStart.gsub!(/\\\\/,'\\')
commentEnd.gsub!("\\",'\\')

p commentStart
p commentEnd

str = "window.requestAnimFrame = (function(callback) {\n        return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame ||\n        function(callback) {\n          window.setTimeout(callback, 1000 / 60);\n        };\n})();\n\nvar canvas = document.getElementById(\"canvas\");\nvar context = canvas.getContext(\"2d\");\n\nvar activeEntities = [];\nvar passiveEntities = [];\n\nfunction addActiveEntity(e)\n{\n    acitveEntities.append(e);\n}\n\nfunction addPassiveEntity(e)\n{\n    passiveEntities.append(e);\n}\n\n"
p "#{commentStart}(.[\s]*.)*#{commentEnd}"	
# need \/\*(.[\s]*.)*\*\/
metaData = str.gsub(/["]/,'\\\"').gsub(/[\n\t\\]/,'').match(/#{commentStart}(.[\s]*.)*#{commentEnd}/)
p metaData
=end

