extends Node

## client绑定的账号
var bindAccount : String
## 预制件，加载在内存随时调用
var loginGui = load("res://res/scene/login.tscn")
## 用于存储当前实例
var instanGlobal : Node
## 用户的私有数据集
var account_data : Dictionary

signal logOn(user,data,code)

func setLoginGui():
	var instan = loginGui.instantiate()
	get_viewport().call_deferred("add_child",instan)
	instanGlobal = instan

@rpc(call_remote,any_peer,unreliable_ordered)
func login():
	pass
@rpc(call_remote,any_peer,unreliable_ordered)
func login_return(user:String,data : Dictionary,code : int):
	if code == 0:
		print("登陆成功！")
		if instanGlobal != null:
			instanGlobal.queue_free()
			bindAccount = user
			account_data = data
			emit_signal("logOn",user,data,code)
			pass
		else:
			print_debug("登录UI不存在！")
			pass
		pass
	else:
		printerr("登录失败，错误码：",code)
		if instanGlobal != null:
			var tip = load("res://res/scene/tip.tscn")
			tip = tip.instantiate()
			get_viewport().add_child(tip)
			tip.get_child(0).text = "登录失败，错误码："+str(code)
			pass
		else:
			print_debug("登录UI不存在！")
			pass
		pass
