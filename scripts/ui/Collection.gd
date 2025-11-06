extends Control

@onready var collection_grid = $MarginContainer/VBoxContainer/CollectionGrid/GridContainer
@onready var back_button = $MarginContainer/VBoxContainer/BackButton
@onready var header_label = $MarginContainer/VBoxContainer/Header

func _ready():
	show_collection()
	back_button.pressed.connect(_on_back_button_pressed)

func show_collection():
	# Limpa cartas antigas
	for child in collection_grid.get_children():
		child.queue_free()
	var player = null
	if Engine.has_singleton("PlayerManager"):
		player = PlayerManager.get_current_player()
	if not player or player == null:
		header_label.text = "Nenhum jogador logado!"
		return

	var cards = player.collection
	header_label.text = "Sua coleção: " + str(cards.size()) + " cartas"

	var card_display_scene = preload("res://scenes/ui/CardDisplay.tscn")
	for card in cards:
		var card_display = card_display_scene.instantiate()
		card_display.setup_card(card)
		collection_grid.add_child(card_display)

func _on_back_button_pressed():
	SceneManager.change_scene("res://scenes/main/Lobby.tscn")
