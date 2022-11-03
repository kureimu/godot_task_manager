extends Node


## 解析 csv 文件
## @path 文件路径
## @key 以数据中的哪个值作为 key 值记录到字典中
## @return 以第一行数据作为 key 值，记录成字典形式
func parse_csv_file(path: String, key: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)

	# 没有数据则返回空字典
	# 以 ; 分号进行分隔，具体需要自己打开 csv 文件查看是那种字符进行分隔的
	var temp = file.get_csv_line(";")
	if temp.size() <= 1:
		return {}

	# 第一行做为 key
	var keys = []
	for i in temp:
		keys.push_back(i)

	# 读取一行，但不对数据进行操作（这样等于是跳过了这一行）
	# 如果第二行就是要读取的数据，那么就不必加这一行代码
	file.get_csv_line()

	# 获取数据记录到字典中，字典可以方便的获取每个数据
	# 比如我们以数据的名字那一列作为 key 值
	# 那么我们只用通过 名字 来获取那一行数据
	var data_list = {}
	var err_count = 0	# 数据错误次数
	temp = file.get_csv_line(";")
	while temp.size() > 1:
		# 数据列数和 key 数量不一致，则跳过
		if temp.size() != keys.size():
			err_count += 1
			if err_count > 10:	# 错误超过 10 次，则不再读取
				break
			temp = file.get_csv_line(";")
			print_debug("数据有误，与第一行不一致 n: %d, k: %d" % [temp.size(), keys.size()])
			continue

		# 每行数据保存到字典中
		var data = {}
		for idx in range(temp.size()):
			data[keys[idx]] = temp[idx]
		data_list[data[key]] = data

		# 读取下一行数据
		temp = file.get_csv_line(";")

	file.close()
	return data_list
