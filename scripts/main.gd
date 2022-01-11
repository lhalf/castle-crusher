extends Node

const port = 44444
const max_players = 2

var ip
var background_server = false

func _ready():
	if background_server:
		create_server()
		_hide_menu()
	else:
		var _connect_pressed = $display/menu/connect.connect("pressed", self, "_on_connect_pressed")
		var _debug_pressed = $display/menu/debug.connect("pressed", self, "_on_debug_pressed")

func _on_connect_pressed():
	_set_ip($display/menu/textbox.text)
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var _connected_to_server = get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	var _connection_failed = get_tree().connect("connection_failed", self, "_on_connection_failed")
	var _server_disconnected = get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	var network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

func _set_ip(input):
	if input == "Enter IP here...":
		ip = "localhost"
	else:
		ip = input

func _on_debug_pressed():
	create_server()
	_hide_menu()
	#DEBUG
	#_create_debug_player()

func _create_debug_player():
	var my_id = "100"
	var player = preload("res://scenes/player.tscn").instance()
	player.name = str(my_id)
	$players.add_child(player)
	player.get_node("build_camera").current = false
	$players.get_node(my_id).get_node("build_camera").current = true
	$players.get_node(my_id).get_node("build_camera").get_node("build_menu").get_node("controls").show()
	$players.get_node(my_id).get_node("build_camera").get_node("build_menu").get_node("objects").show()
	$players.get_node(my_id).get_node("build_camera").get_node("build_menu").get_node("timer").show()
	$players.get_node(my_id).get_node("build_camera").get_node("build_menu").get_node("timer").get_node("timer").start()
	$display/waiting.hide()

func _on_peer_connected(id):
	create_player(id, true)

func _on_peer_disconnected(id):
	if get_tree().get_network_unique_id() != 1:
		var _reloaded = get_tree().reload_current_scene()
		call_deferred("remove_player",id)
		get_tree().call_deferred("set_network_peer",null)
		call_deferred("queue_free")
	else:
		for p in $players.get_children():
			p.call_deferred("queue_free")

func _on_connected_to_server():
	var id = get_tree().get_network_unique_id()
	_hide_menu()
	$display/waiting.show()
	create_player(id, false)

func _on_connection_failed():
	get_tree().set_network_peer(null)

func _on_server_disconnected():
	var _reloaded = get_tree().reload_current_scene()

func create_server():
	var _peer_connected = get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	var _peer_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	var network = NetworkedMultiplayerENet.new()
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)

func create_player(id, _is_peer):
	#don't create a server player
	if id != 1:
		var player = preload("res://scenes/player.tscn").instance()
		player.name = str(id)
		$players.add_child(player)
		player.get_node("build_camera").current = false
		if $players.get_child_count() == 2 and get_tree().get_network_unique_id() != 1:
			var my_id = str(get_tree().get_network_unique_id())
			$players.get_node(my_id).get_node("build_camera").current = true
			$players.get_node(my_id).get_node("build_camera").get_node("build_menu").get_node("controls").show()
			$players.get_node(my_id).get_node("build_camera").get_node("build_menu").get_node("objects").show()
			$players.get_node(my_id).get_node("build_camera").get_node("build_menu").get_node("timer").show()
			#DEBUG
			#$players.get_node(my_id).get_node("build_camera").get_node("build_menu").get_node("timer").get_node("timer").start()
			$display/waiting.hide()
			#atm player might be able to tap whilst waiting, maybe do a check or attach the 
			#build menu at this step so they can't click until this step is called

func remove_player(id):
	$players.get_node(str(id)).free()

func _on_textbox_focus_entered():
	$display/menu/textbox.set_text("")
	pass

func _hide_menu():
	$display/menu.hide()
	$display/menu_camera.current = false
