extends Control

@onready var backbutton = $BackButton

func _ready():
	backbutton.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/main/Lobby.tscn")
