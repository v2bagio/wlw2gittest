extends Node

@onready var ui_layer: CanvasLayer = $UI
@onready var interface: Control = $UI/Interface
@onready var center_label: Label = $UI/Interface/CenterLabel
@onready var start_button: Button = $UI/Interface/StartButton

func _ready():
	print("🌳 Ygg iniciando...")
	
	setup_ui()
	
	show_welcome_message()
	
func setup_ui():
	center_label.text = "🌳 YGG"
	center_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	interface.anchors_preset = Control.PRESET_FULL_RECT
	center_label.anchors_preset = Control.PRESET_FULL_RECT
	
func show_welcome_message():
	print("Hello world!")
	print("bora bora bora")
	await get_tree().create_timer(3.0).timeout
	center_label.text = "Clica aí"
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		print("🔑 Clicou mesmo: ", event.as_text())
		center_label.text = "Working"
		
func _on_start_button_pressed():
	SceneManager.change_scene("res://scenes/main/Login.tscn")
	
