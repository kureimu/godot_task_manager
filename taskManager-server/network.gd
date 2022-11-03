extends Node

## 服务器IP
var server_ip = "127.0.0.1"
## 服务器端口
var server_port = 3649
## 最大连接数
const limitedClientNum = 120
## 服务器实例
var server = ENetMultiplayerPeer.new()


func _ready():
	server.create_server(server_port,limitedClientNum)
	multiplayer.multiplayer_peer = server
	var id = multiplayer.get_unique_id()
	set_multiplayer_authority(1)
	print(multiplayer.is_server())
	multiplayer.connect("peer_connected",Callable(self,"connected"))
	multiplayer.connect("peer_disconnected",Callable(self,"disconnected"))

func connected(id):
	print("客户端连接：",id)
	# 挂列表
	account.accountBindList[str(id)] = null
	pass

func disconnected(id):
	print("客户端断开：",id)
	# 删项
	account.accountBindList.erase(str(id))
	pass

## 心跳包
@rpc(call_remote,any_peer,unreliable_ordered)
func heart():
	pass
