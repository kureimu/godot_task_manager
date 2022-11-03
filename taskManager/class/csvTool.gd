extends Node
class_name csvTool

## 获得所有字段到一个一维数组
static func CSVstr2array(splitStr : String) -> Array:
	var newStr := ""
	var sList := PackedStringArray()
	
	var isSplice := false
	var array := PackedStringArray()
	array = splitStr.split(",")
	for str in array:
		# 如果需要splice
		if (!str.is_empty() and str.count("\"") > 0):
			var firstChar := str.substr(0)
			var lastChar := ""
			if (str.length() > 0):
				lastChar = str.substr(str.length() - 1, 1);
				pass
			if (firstChar == "\"" and !lastChar == "\""):
				isSplice = true
				pass
			if (lastChar == "\""):
				if (!isSplice):
					newStr += str
					pass
				else:
					newStr = newStr + "," + str
				isSplice = false
				pass
			pass
		else:
			if (newStr.is_empty()):
				newStr += str
				pass
			pass
		
		if (isSplice):
			# 添加因拆分时丢失的逗号
			if (newStr.is_empty()):
				newStr += str
			else:
				newStr = newStr + "," + str
		else:
			if "\n" in newStr and newStr[0] != "\"" and !newStr.ends_with("\""):
				var last = newStr.replace("\"","").strip_edges().split("\n")
				sList.append(last[0])
				sList.append(last[1])
				pass
			else:
				sList.append(newStr.replace("\"","").strip_edges())
			newStr = ""
	return Array(sList)

## 获取CSV文件到一个二维数组
static func getCsvArr(filePath : String) -> Array:
	var output := []
	var file = FileAccess.open(filePath,FileAccess.READ)
	var state := false
	while state == false:
		var line := file.get_csv_line()
		if line.size() != 1 and !line[0].is_empty():
			output.append(line)
		else:
			state = true
	return output

## 保存Csv文件
static func saveCsvLine(filePath : String,values :PackedStringArray,line : int):
	var file = FileAccess.open(filePath,FileAccess.WRITE)
	var readfile = FileAccess.open(filePath,FileAccess.READ)
	var cursor := 1
	if line >= 1:
		while cursor != line:
			cursor += 1
			var readline = readfile.get_csv_line()
			file.store_csv_line(readline)
		file.store_csv_line(values)
		pass
	else:
		printerr("请输入1或1以上的数字")
	pass
