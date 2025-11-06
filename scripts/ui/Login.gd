extends Control

@onready var email_input = $VBoxContainer/User
@onready var password_input = $VBoxContainer/Password
@onready var login_button = $VBoxContainer/Entrar
@onready var error_label = $VBoxContainer/ErrorLabel

func _ready():
	login_button.pressed.connect(_on_login_button_pressed)
	error_label.visible = false
	
func _on_login_button_pressed():
	var email = email_input.text.strip_edges()
	var senha = password_input.text.strip_edges()
	error_label.visible = false
	
	if email == "" or senha == "":
		show_error("Preencha todos os campos.")
		return
	if not email.contains("@") or not email.contains("."):
		show_error("Email inválido.")
		return
	if senha.length() < 6:
		show_error("Senha deve ter pelo menos 6 caracteres.")
		return
	print("Login válido! Prosseguir...")

func show_error(msg: String):
	error_label.text = msg
	error_label.visible = true

func _on_entrar_pressed() -> void:
	SceneManager.change_scene("res://scenes/main/Lobby.tscn")
