extends Node

var programsList : Array
var programDataDictionary : Dictionary
## 获取main
@onready var main = get_viewport().get_node("Main")

signal programs_list_recived(data:Array)
signal signed_list(program_name:String,data:Array)
signal programs_data_recived(program_name:String,data:Array)
signal program_meta_data(program_name:String,data:Array)
signal reg_programs(err:int)

func _ready():
	multiplayer.connect("connected_to_server",Callable(self,"_connected"),CONNECT_REFERENCE_COUNTED)
	connect("programs_list_recived",Callable(self,"recive"))

func recive(data : Array):
	print("recive program list:",data)
	for i in main.program_list.get_children():
		i.queue_free()
	for item in data:
		print("item",item)
		var b = Button.new()
		b.custom_minimum_size = Vector2(200,100)
		b.text = str(item)
		# 挂载项目
		main.program_list.add_child(b)
		b.connect("pressed",Callable(self,"btn_pressed").bind(str(item)))
		pass
	pass

func flush_program_list():
	rpc_id(1,"send_program_list")

func btn_pressed(item:String):
	var program_editor
	if account.account_data["level"] == 0:
		program_editor = load("res://res/scene/program_editor_operator.tscn").instantiate()
	elif account.account_data["level"] == 1:
		program_editor = load("res://res/scene/program_editor_manager.tscn").instantiate()
	else:
		printerr("programs:cannot get account level!!")

	program_editor.set_meta("program_name",item)
	main.main.add_child(program_editor)
	pass

func _connected():
	flush_program_list()
	pass


################################################################################

@rpc(call_remote,any_peer,unreliable_ordered)
func send_program_list():
	pass
@rpc(call_remote,any_peer,unreliable_ordered)
func recive_program_list(data : Array):
	programsList = data
	emit_signal("programs_list_recived",data)

@rpc(call_remote,any_peer,unreliable_ordered)
func send_program_data():
	pass
@rpc(call_remote,any_peer,unreliable_ordered)
func recive_program_data(program_name:String,data : Array):
	programDataDictionary[program_name] = data
	emit_signal("programs_data_recived",program_name,data)

## 注册项目
@rpc(call_remote,any_peer,unreliable_ordered)
func _s_reg_programs():
	pass
@rpc(call_remote,any_peer,unreliable_ordered)
func _c_reg_programs(err:int):
	emit_signal("reg_programs",err)

## 保存项目数据
@rpc(call_remote,any_peer,unreliable_ordered)
func _s_save_programs(program_name:String,data:Array):
	pass

## 保存项目元数据
@rpc(call_remote,any_peer,unreliable_ordered)
func _s_save_meta_data():
	pass


## 返回记录列表
@rpc(call_remote,any_peer,unreliable_ordered)
func send_signed_list():
	pass
@rpc(call_remote,any_peer,unreliable_ordered)
func recive_signed_list(program_name:String,data : Array):
	emit_signal("signed_list",program_name,data)

## 客户端申请metadata
@rpc(call_remote,any_peer,unreliable_ordered)
func send_program_meta_data():
	pass
@rpc(call_remote,any_peer,unreliable_ordered)
func recive_program_meta_data(program_name:String,meta_data:Array):
	emit_signal("program_meta_data",program_name,meta_data)


## 应用项目metadata修改
@rpc(call_remote,any_peer,unreliable_ordered)
func modify_program_meta_data():
	pass

## 客户端调用此函数来删除一条记录(metadata)
@rpc(call_remote,any_peer,unreliable_ordered)
func del_program_meta_data(program_name:String,username:String,meta_data_name:String):
	pass
