extends Node

## 拥有一个configFile单例，格式是section为用户名，key为该用户的属性名，value为该属性的值
## 负责管理项目,模板数据是data,数据是metadata

## 注册项目错误码
enum regProgramErr{
	OK,
	PROGRAM_NAME_ALREADY_EXISTS,
	PARAMETER_TOO_LONG
}
## 设置属性错误码
enum setPropertyErr{
	OK,
	NO_PROGRAM,
}
## 设置块类型
enum blockType{
	STRING_BLOCK,
	CHECK_BTN_BLOCK,
	CHECK_BOX_BLOCK,
	SPLIT_BLOCK
}

const programsFilePath = "user://"
const programsFileName = "programs.ini"
const programsFilePwd = "3649"
const save_csv_file_path = "user://csv_export.csv"
var programsFile : ConfigFile
##是否自动保存
var auto_save := true

func get_programs_file() -> ConfigFile:
	return programsFile

func _ready():
	programsFile = load_config_file()
	await get_tree().create_timer(2).timeout

## 设置自动保存
func _set_auto_saver():
	var t = Timer.new()
	t.wait_time = 30
	t.one_shot = false
	t.autostart = true
	add_child(t)
	t.connect("timeout",Callable(self,"save_config_file"))
	pass

func load_config_file() -> ConfigFile:
	var dir = DirAccess.open(programsFilePath)
	if dir.file_exists(programsFilePath + programsFileName):
		## 存在则打开
		var cfgFile = ConfigFile.new()
		var file = cfgFile.load_encrypted_pass(programsFilePath + programsFileName,programsFilePwd)
		if file != OK:
			printerr("打开文件失败:",file)
		return cfgFile
	else:
		## 不存在则创建
		var cfgFile = ConfigFile.new()
		return cfgFile

## 保存文件
func save_config_file() ->int:
	var err = programsFile.save_encrypted_pass(programsFilePath+programsFileName,programsFilePwd)
	if err != OK:
		printerr("保存文件失败：",err)
	return err

## 返回项目是否存在
func has_programs(program_name:String) -> bool:
	return programsFile.has_section(program_name)

## 获得项目列表
func get_programs_list() -> Array:
	return Array(programsFile.get_sections())

## 获得项目模板数据
func get_program_data(program_name:String) -> Array:
	return programsFile.get_value(program_name,"data",[])

## 设置项目模板数据
func set_program_data(program_name:String,data:Array):
	programsFile.set_value(program_name,"data",data)
	save_config_file()

## 设置项目元数据
## metadata[0]:创建者
## metadata[1]:创建时间
## metadata[2]:数据本据
func set_all_program_meta_data(program_name:String,username:String,data:Array):
	programsFile.set_value(program_name,"metadata",data)
	save_config_file()

## 设置项目元数据
## metadata[0]:创建者
## metadata[1]:创建时间
## metadata[2]:数据本据
func set_program_meta_data(program_name:String,username:String,data:Array):
	var tempdata : Array = programsFile.get_value(program_name,"metadata",[])
	var now_time = Time.get_datetime_string_from_system()
	tempdata.append([username,now_time,data])
	programsFile.set_value(program_name,"metadata",tempdata)
	save_config_file()

## 获取项目元数据 -> 数组
func get_all_program_meta_data(program_name:String) -> Array:
	return programsFile.get_value(program_name,"metadata",[])

## 删除所有项目元数据
func clean_all_program_meta_data(program_name:String):
	programsFile.set_value(program_name,"metadata",[])

## 获得指定项目的指定用户用户的元数据
func get_user_program_meta_data(program_name:String,username:String) -> Array:
	var output :=  []
	var all_meta_data = get_all_program_meta_data(program_name)
	for item in all_meta_data:
		if item[0] == username:
			output.append(item)
	return output

## 获得用户记录列表
func get_signed_list(program_name:String,username:String) -> Array:
	var output : Array
	var metadata = programsFile.get_value(program_name,"metadata",[])
	for i in metadata:
		if i[0] == username:
			output.append(i[1])
	return output

## 添加项目(返回错误码)
## @programslevel OPERATOR/MANAGER 项目等级
## @programs_name 用户名
## @userpassword 用户密码
func reg_programs(programs_name:String,creator:String) -> int:
	if !has_programs(programs_name):
		if programs_name.length() <= 20 and creator.length() <= 20:
			programsFile.set_value(programs_name,"creator",creator)
			save_config_file()
			return regProgramErr.OK
			pass
		else:
			return regProgramErr.PARAMETER_TOO_LONG
		pass
	else:
		return regProgramErr.PROGRAM_NAME_ALREADY_EXISTS
	pass

## 设置属性(返回错误码)
## 清空属性就是value=null
## @programs_name 项目名
## @key 属性名
## @value 属性值
func set_programs_property(programs_name:String,key:String,value:Variant) -> int:
	programsFile.set_value(programs_name,key,value)
	save_config_file()
	return setPropertyErr.OK

## 导出项目数据记录到CSV文件
func write_programs_metadata2csv_file(program_name:String):
	# 创建或打开文件
	var file = FileAccess.open(save_csv_file_path, FileAccess.WRITE_READ)
	# 获得项目模板
	var programs_data = get_program_data(program_name)
	print("programs_data",programs_data)
	var title_line := PackedStringArray()
	for a in programs_data:
		var type = a["type"]
		title_line.append(a["title"])
		pass
	# 保存一行标题
	file.store_csv_line(title_line)
	# 获得metadata
	var program_meta_data = get_all_program_meta_data(program_name)
	var err = FileAccess.get_open_error()
	var wait_data : Array
	if err != OK:
		printerr("读写文件错误！错误码：",err)
	for item in program_meta_data:
		var meta_data = item[2]
		# 获得待处理保留数据
		var line = []
		for block_meta_data in meta_data:
			var type = block_meta_data["type"]
			match type:
				0:
					# split_block
					line.append("")
					pass
				1:
					# string_block
					line.append(block_meta_data["content"])
					pass
				2:
					# check_btn_block
					line.append(block_meta_data["result"])
					pass
				3:
					# check_box_block
					line.append(block_meta_data["result"])
					pass
		wait_data.append(line)
	for item in wait_data:
		var output_meta_data = PackedStringArray()
		print(item)
		var num = -1
		for i in programs_data:
			num += 1
			var type = i["type"]
			match type:
				0:
					# split_block
					output_meta_data.append(i["title"])
					pass
				1:
					# string_block
					output_meta_data.append(item[num])
					pass
				2:
					# check_btn_block
					var result = item[num]
					if result:
						output_meta_data.append("是")
						pass
					else:
						output_meta_data.append("否")
						pass
					pass
				3:
					# check_box_block
					var btn_arr:Array
					btn_arr = i["btn_arr"]
					var result : int
					result = item[num]
					if result == -1:output_meta_data.append("未选择")
					else:
						output_meta_data.append(btn_arr[result])
						pass
					pass
		file.store_csv_line(output_meta_data)

#################################################################################

## 项目列表
@rpc(call_remote,any_peer,unreliable_ordered)
func send_program_list():
	rpc_id(multiplayer.get_remote_sender_id(),"recive_program_list",get_programs_list())
	pass
@rpc(call_remote,any_peer,unreliable_ordered)
func recive_program_list():
	pass

## 项目模板数据
@rpc(call_remote,any_peer,unreliable_ordered)
func send_program_data(program_name:String):
	rpc_id(multiplayer.get_remote_sender_id(),"recive_program_data",program_name,get_program_data(program_name))
	pass
@rpc(call_remote,any_peer,unreliable_ordered)
func recive_program_data():
	pass

## 保存项目模板
@rpc(call_remote,any_peer,unreliable_ordered)
func _s_save_programs(program_name:String,data:Array):
	set_program_data(program_name,data)

## 注册项目
@rpc(call_remote,any_peer,unreliable_ordered)
func _s_reg_programs(program_name:String):
	var err = reg_programs(
		program_name,account.id2username(
			multiplayer.get_remote_sender_id()
			)
		)
	rpc_id(multiplayer.get_remote_sender_id(),"_c_reg_programs",err)
	pass
@rpc(call_remote,any_peer,unreliable_ordered)
func _c_reg_programs():
	pass

## 保存元数据
@rpc(call_remote,any_peer,unreliable_ordered)
func _s_save_meta_data(program_name:String,username:String,data:Array):
	set_program_meta_data(program_name,username,data)
	pass

## 返回记录列表
@rpc(call_remote,any_peer,unreliable_ordered)
func send_signed_list(program_name:String,username:String):
	rpc_id(multiplayer.get_remote_sender_id(),"recive_signed_list",program_name,get_signed_list(program_name,username))
@rpc(call_remote,any_peer,unreliable_ordered)
func recive_signed_list():
	pass

## 客户端申请metadata
@rpc(call_remote,any_peer,unreliable_ordered)
func send_program_meta_data(program_name:String,username:String):
	var meta_data_arr = get_user_program_meta_data(program_name,username)
	var output:Array
	# 过滤出属于此用户的Data
	for item in meta_data_arr:
		if item[0] == username:
			output.append(item)
	rpc_id(multiplayer.get_remote_sender_id(),"recive_program_meta_data",program_name,output)
@rpc(call_remote,any_peer,unreliable_ordered)
func recive_program_meta_data():
	pass

## 客户端调用此函数应用项目metadata修改
## @program_name 项目名
## @username 用户名
## @meta_data_name 根据创建时间
## @meta_data 修改后的数据(不包含creator,create time)
@rpc(call_remote,any_peer,unreliable_ordered)
func modify_program_meta_data(program_name:String,username:String,meta_data_name:String,meta_data:Array):
	var meta_data_arr = get_user_program_meta_data(program_name,username)
	# 过滤出属于此用户的Data
	for item in meta_data_arr:
		if item[0] == username and meta_data_name == item[1]:
			item[2] = meta_data
			pass

## 客户端调用此函数来删除一条记录(metadata)
@rpc(call_remote,any_peer,unreliable_ordered)
func del_program_meta_data(program_name:String,username:String,meta_data_name:String):
	var meta_data_arr = get_user_program_meta_data(program_name,username)
	# 过滤出属于此用户的Data
	for item in meta_data_arr:
		if item[0] == username and meta_data_name == item[1]:
			meta_data_arr.erase(item)
			pass
	set_all_program_meta_data(program_name,username,meta_data_arr)
