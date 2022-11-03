extends Node
class_name stringTool

## 获取字符串某行
static func get_row(text : String,rowCount : int) -> String:
	var test : String = text.get_slice("\n",rowCount)
	return test

## 获取字符串一共有多少行
static func get_row_count(text : String) -> int:
	var test : int = text.get_slice_count("\n")
	return test
