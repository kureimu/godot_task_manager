extends Node

## 拥有一个configFile单例，格式是section为用户名，key为该用户的属性名，value为该属性的值

## 账号等级
## 0是操作员，负责为项目添加记录
## 1是管理员，负责管理项目
enum accountLevel{
	OPERATOR,
	MANAGER
}

## 注册账号错误码
enum regUserErr{
	OK,
	USERNAME_ALREADY_EXISTS,
	PARAMETER_TOO_LONG
}
## 登录账号错误码
enum logUserErr{
	OK,
	NO_USER,
	PARAMETER_TOO_LONG,
	NO_PASSWORD,
	PASSWORD_ERR
}
## 设置属性错误码
enum setPropertyErr{
	OK,
	NO_USER,
}

const accountFilePath = "user://"
const accountFileName = "users.ini"
const accountFilePwd = "3649"
var accountFile : ConfigFile
##是否自动保存
var auto_save := true
## 当前已连接的客户端与账号的绑定情况
## key是账号，值为null就是没有绑定账号，值为int就是绑定了账号且该值为账号名{"string":"string"}
## @accountBindList.keys 获得客户端连接列表
var accountBindList := {}

func get_account_file() -> ConfigFile:
	return accountFile

func _ready():
	accountFile = load_config_file()

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
	var dir = DirAccess.open(accountFilePath)
	if dir.file_exists(accountFilePath + accountFileName):
		## 存在则打开
		var cfgFile = ConfigFile.new()
		var file = cfgFile.load_encrypted_pass(accountFilePath + accountFileName,accountFilePwd)
		if file != OK:
			printerr("打开文件失败:",file)
		return cfgFile
	else:
		## 不存在则创建
		var cfgFile = ConfigFile.new()
		return cfgFile

## 保存文件
func save_config_file() ->int:
	var err = accountFile.save_encrypted_pass(accountFilePath+accountFileName,accountFilePwd)
	if err != OK:
		printerr("保存文件失败：",err)
	return err

## 返回账号是否存在
func has_account(username:String) -> bool:
	return accountFile.has_section(username)

## 获得用户列表
func get_account_list() -> Array:
	return Array(accountFile.get_sections())

## 注册账号(返回错误码)
## @accountlevel OPERATOR/MANAGER 账号等级
## @username 用户名
## @userpassword 用户密码
func reg_account(username:String,userpassword:String,accountlevel:int) -> int:
	if !has_account(username):
		if username.length() <= 20 and userpassword.length() <= 20:
			accountFile.set_value(username,"password",userpassword)
			var data = accountFile.get_value(username,"data",{})
			data["level"] = accountlevel
			accountFile.set_value(username,"data",data)
			save_config_file()
			return regUserErr.OK
			pass
		else:
			return regUserErr.PARAMETER_TOO_LONG
		pass
	else:
		return regUserErr.USERNAME_ALREADY_EXISTS
	pass

## 登录账号(返回错误码)
## @username 用户名
## @userpassword 用户密码
func login_account(username:String,userpassword:String) -> int:
	if has_account(username):
		if username.length() <= 20 and userpassword.length() <= 20:
			var password = accountFile.get_value(username,"password")
			if password != null:
				if userpassword == password:
					return logUserErr.OK
					pass
				else:
					return logUserErr.PASSWORD_ERR
					pass
				pass
			else:
				return logUserErr.NO_PASSWORD
			pass
		else:
			return logUserErr.PARAMETER_TOO_LONG
		pass
	else:
		return logUserErr.NO_USER
	pass

## 删除账号
func del_account(username:String) -> int:
	if has_account(username):
		accountFile.erase_section(username)
		return setPropertyErr.OK
	else:
		return setPropertyErr.NO_USER
	pass

## 设置账号data属性(返回错误码)
## @username 用户名
## @key 属性名
## @value 属性值
func set_account_property(username:String,key:String,value:Variant) -> int:
	if has_account(username):
		var userdata = accountFile.get_value(username,"data",{})
		userdata[key] = value
		accountFile.set_value(username,"data",userdata)
		save_config_file()
		return setPropertyErr.OK
	else:
		return setPropertyErr.NO_USER

## 获取属性(返回错误码)
## @username 用户名
func get_account_property(username:String) -> Dictionary:
	var userdata = accountFile.get_value(username,"data",{})
	return userdata


## 清除属性(返回错误码)
## @username 用户名
## @key 属性名
## @value 属性值
func clear_account_property(username:String,key:String) -> int:
	if has_account(username):
		var userdata : Dictionary = accountFile.get_value(username,"data",{})
		userdata.erase(key)
		accountFile.set_value(username,"data",userdata)
		save_config_file()
		return setPropertyErr.OK
	else:
		return setPropertyErr.NO_USER

## 登录
@rpc(call_remote,any_peer,unreliable_ordered)
func login(user:String,pwd:String):
	var logState = account.login_account(user,pwd)
	if logState == account.logUserErr.OK:
		accountBindList[str(multiplayer.get_remote_sender_id())] = str(user)
	rpc_id(multiplayer.get_remote_sender_id(),"login_return",user,get_account_property(user),logState)
@rpc(call_remote,any_peer,unreliable_ordered)
func login_return():
	pass

func id2username(id:int) -> String:
	return accountBindList[str(id)]
