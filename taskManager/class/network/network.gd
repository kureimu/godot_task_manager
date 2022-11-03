extends Node

## 服务器基础配置
var server_ip = "127.0.0.1"
var server_port = 3649
## 是否已经连接到服务器
var isConnected := false

func _ready():
	connectToServer()
	setSignal()
	await get_tree().create_timer(0.1).timeout
	heartPack()

func connectToServer():
	var server = ENetMultiplayerPeer.new()
	server.create_client(server_ip,server_port)
	server.get_peer(1)
	multiplayer.set_multiplayer_peer(server)
	await get_tree().create_timer(1).timeout
#	var id = multiplayer.get_unique_id()
#	set_multiplayer_authority(id)

func setSignal():
	multiplayer.connect("connected_to_server",Callable(self,"_connected"),CONNECT_REFERENCE_COUNTED)
	multiplayer.connect("connection_failed",Callable(self,"_failed"),CONNECT_REFERENCE_COUNTED)
	multiplayer.connect("server_disconnected",Callable(self,"_disconnected"),CONNECT_REFERENCE_COUNTED)
	multiplayer.connect("peer_connected",Callable(self,"_peer_connected"),CONNECT_REFERENCE_COUNTED)
	multiplayer.connect("peer_disconnected",Callable(self,"_peer_disconnected"),CONNECT_REFERENCE_COUNTED)

func heartPack():
	while true:
		if isConnected:
			if loading.visible == true:
				loading.hide()
			rpc_id(1,"heart")
		else:
			loading.show()
			print("服务器未连接")
		await get_tree().create_timer(5).timeout
	pass

func _connected():
	print("连接成功")
	isConnected = true
	if loading.visible == true:
		loading.hide()
	pass

func _failed():
	print("连接失败")
	isConnected = false
	connectToServer()
	loading.show()
	pass

func _disconnected():
	print("服务器断开")
	isConnected = false
	connectToServer()
	loading.show()
	pass

func _peer_connected(id):
	print("peer连接成功:",id)
	print("当前所有连接：",multiplayer.get_peers())
	if loading.visible == true:
		loading.hide()
	if id == 1:
		isConnected = true

func _peer_disconnected(id):
	print("peer断开:",id)
	print("当前所有连接：",multiplayer.get_peers())
	if id == 1:
		isConnected = false
		loading.show()

## 心跳包
@rpc(call_remote,any_peer,unreliable_ordered)
func heart():
	pass
