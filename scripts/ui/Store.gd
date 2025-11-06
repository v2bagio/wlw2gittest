extends Control

@onready var packs_container = $VBoxContainer/PacksContainer
@onready var info_label = $VBoxContainer/InfoLabel
@onready var buy_button = $VBoxContainer/BuyButton
@onready var back_button = $VBoxContainer/BackButton

var available_packs = []
var selected_pack = null

func _ready():
	load_packs()
	buy_button.pressed.connect(_on_buy_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)

func load_packs():
	# Exemplo: apenas um pacote de teste. Expanda depois para listar vários!
	var test_pack = CardGenerator.create_test_pack()
	available_packs = [test_pack]
	selected_pack = test_pack
	info_label.text = "Pacote: %s | Preço: %d moedas" % [test_pack.pack_name, test_pack.cost_coins]

func _on_buy_button_pressed():
	var player = PlayerManager.get_current_player()
	if not player:
		info_label.text = "Nenhum jogador logado!"
		return
	if player.coins < selected_pack.cost_coins:
		info_label.text = "Moedas insuficientes!"
		return

	var new_cards = PlayerManager.buy_pack_with_coins(selected_pack)
	info_label.text = "Pacote aberto! %d cartas novas adicionadas." % new_cards.size()
	# Opcional: mostrar as cartas novas em um painel/modal

func _on_back_button_pressed():
	SceneManager.change_scene("res://scenes/main/Lobby.tscn")
