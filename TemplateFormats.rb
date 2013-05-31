def getFormats
	formats = {}
	formats["javascript"] = {"commentStart"=>"\/\*", "commentEnd"=>"\*\/"}
	formats["html"] = {"commentStart"=>"<!--", "commentEnd"=>"-->"}
	return formats
end