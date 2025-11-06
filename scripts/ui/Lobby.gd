extends Control

@onready var play_button = $CenterContainer/VBoxContainer/HBoxContainer/PlayButton
@onready var collection_button = $CenterContainer/VBoxContainer/HBoxContainer/CollectionButton
@onready var shop_button = $CenterContainer/VBoxContainer/HBoxContainer/ShopButton
@onready var trade_button = $CenterContainer/VBoxContainer/HBoxContainer/TradeButton
@onready var settings_button = $CenterContainer/VBoxContainer/HBoxContainer/SettingsButton
@onready var exit_button = $CenterContainer/VBoxContainer/HBoxContainer/ExitButton

func _ready():
	print("🏠 Lobby carregado")
	
	# Conectar botões
	play_button.pressed.connect(_on_play_pressed)
	collection_button.pressed.connect(_on_collection_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	trade_button.pressed.connect(_on_trade_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	if PlayerManager and not PlayerManager.is_player_logged_in():
		var user = PlayerManager.create_new_player("testuser")
		PlayerManager.login_player(user)

func _on_play_pressed():
	SceneManager.change_scene("res://scenes/lobby/PlayMenu.tscn")

func _on_collection_pressed():
	SceneManager.change_scene("res://scenes/lobby/Collection.tscn")

func _on_shop_pressed():
	SceneManager.change_scene("res://scenes/lobby/Store.tscn")

func _on_trade_pressed():
	SceneManager.change_scene("res://scenes/lobby/Trade.tscn")

func _on_settings_pressed():
	SceneManager.change_scene("res://scenes/lobby/Settings.tscn")

func _on_exit_pressed():
	get_tree().quit()
