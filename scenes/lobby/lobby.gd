extends Control

# ----------------------------
# Configuration
# ----------------------------
const DEFAULT_PORT: int = 8910
const GAME_SCENE: PackedScene = preload("res://Test World/World.tscn")  # change to your main game scene

# ----------------------------
# UI references
# ----------------------------
@onready var host_btn: Button = $Panel/HostButton
@onready var join_btn: Button = $Panel/JoinButton
@onready var address_input: LineEdit = $Panel/AddressLineEdit
@onready var status_label: Label = $StatusLabel

# ----------------------------
# Initialization
# ----------------------------
func _ready():
	host_btn.pressed.connect(_on_host_pressed)
	join_btn.pressed.connect(_on_join_pressed)

	var mp_api: MultiplayerAPI = get_tree().get_multiplayer()
	mp_api.peer_connected.connect(_on_peer_connected)
	mp_api.peer_disconnected.connect(_on_peer_disconnected)
	mp_api.connection_failed.connect(_on_connection_failed)
	mp_api.server_disconnected.connect(_on_server_disconnected)

# ----------------------------
# Host game
# ----------------------------
func _on_host_pressed() -> void:
	var ip: String = address_input.text
	if ip == "-1":
		# Single-player mode
		_set_status("Single Player Mode", true)
		_start_game_singleplayer()
		host_btn.disabled = true
		join_btn.disabled = true
		return

	# Multiplayer host
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var err: int = peer.create_server(DEFAULT_PORT, 2)
	if err != OK:
		_set_status("Cannot host: port in use", false)
		return

	var mp_api: MultiplayerAPI = get_tree().get_multiplayer()
	mp_api.multiplayer_peer = peer

	_set_status("Hosting, waiting for player...", true)
	host_btn.disabled = true
	join_btn.disabled = true

# ----------------------------
# Join game
# ----------------------------
func _on_join_pressed() -> void:
	var ip: String = address_input.text
	if ip == "":
		_set_status("Enter a valid IP", false)
		return

	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)

	var mp_api: MultiplayerAPI = get_tree().get_multiplayer()
	mp_api.multiplayer_peer = peer

	_set_status("Connecting...", true)
	host_btn.disabled = true
	join_btn.disabled = true

# ----------------------------
# Peer connected / disconnected
# ----------------------------
func _on_peer_connected(id: int) -> void:
	_set_status("Player connected: %d" % id, true)
	# Start the multiplayer game once a player joins
	_start_game_multiplayer()

func _on_peer_disconnected(id: int) -> void:
	_set_status("Player disconnected: %d" % id, false)

func _on_connection_failed() -> void:
	_set_status("Failed to connect", false)
	host_btn.disabled = false
	join_btn.disabled = false

func _on_server_disconnected() -> void:
	_set_status("Server disconnected", false)
	host_btn.disabled = false
	join_btn.disabled = false

# ----------------------------
# Start game (single-player)
# ----------------------------
func _start_game_singleplayer() -> void:
	get_tree().change_scene_to_packed(GAME_SCENE)

# ----------------------------
# Start game (multiplayer)
# ----------------------------
func _start_game_multiplayer() -> void:
	get_tree().change_scene_to(GAME_SCENE)

# ----------------------------
# Status update
# ----------------------------
func _set_status(text: String, ok: bool) -> void:
	status_label.text = text
