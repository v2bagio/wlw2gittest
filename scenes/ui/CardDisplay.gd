extends Control
class_name CardDisplay

# ===== REFERÊNCIAS DOS NÓS =====
@onready var background: ColorRect = $Background
@onready var card_image: TextureRect = $VBoxContainer/CardImage
@onready var name_label: Label = $VBoxContainer/HeaderContainer/NameLabel
@onready var rarity_icon: TextureRect = $VBoxContainer/HeaderContainer/RarityIcon
@onready var species_label: Label = $VBoxContainer/SpeciesLabel
@onready var habitat_label: Label = $VBoxContainer/InfoContainer/HabitatLabel
@onready var conservation_label: Label = $VBoxContainer/InfoContainer/ConservationLabel
@onready var photographer_label: Label = $VBoxContainer/InfoContainer/PhotographerLabel
@onready var power_total_label: Label = $VBoxContainer/PowerTotalLabel

# Referências dos atributos
@onready var strength_label: Label = $VBoxContainer/AttributesContainer/StrengthLabel
@onready var density_label: Label = $VBoxContainer/AttributesContainer/DensityLabel
@onready var power_weight_label: Label = $VBoxContainer/AttributesContainer/PowerWeightLabel
@onready var biomech_label: Label = $VBoxContainer/AttributesContainer/BiomechLabel
@onready var material_label: Label = $VBoxContainer/AttributesContainer/MaterialLabel
@onready var accel_label: Label = $VBoxContainer/AttributesContainer/AccelLabel
@onready var pressure_label: Label = $VBoxContainer/AttributesContainer/PressureLabel
@onready var metabolic_label: Label = $VBoxContainer/AttributesContainer/MetabolicLabel

# ===== DADOS DA CARTA =====
var card_data: Card
var is_interactive: bool = true
var scale_on_hover: bool = true

# Sinais
signal card_clicked(card: Card)
signal card_hovered(card: Card)

# ===== INICIALIZAÇÃO =====

func _ready():
	# Configurar interações
	if is_interactive:
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		gui_input.connect(_on_gui_input)
	
	# Configurar tamanho padrão
	custom_minimum_size = Vector2(200, 300)
	
	# Estilo padrão
	setup_default_style()

func setup_default_style():
	# Background padrão
	if background:
		background.color = Color.WHITE
		background.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		background.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Configurar labels
	setup_label_styles()

func setup_label_styles():
	var labels = [name_label, species_label, habitat_label, conservation_label, 
				  photographer_label, power_total_label]
	
	for label in labels:
		if label:
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

# ===== CONFIGURAÇÃO DA CARTA =====

func setup_card(card: Card):
	if not card:
		print("⚠️  CardDisplay: carta nula recebida")
		return
	
	card_data = card
	print("🎨 Configurando CardDisplay para: %s" % card.name)
	
	# Informações básicas
	if name_label:
		name_label.text = card.name
	
	if species_label:
		species_label.text = card.species_name
	
	# Atributos
	setup_attributes(card)
	
	# Informações complementares
	setup_info_labels(card)
	
	# Visual da raridade
	setup_rarity_visual(card)
	
	# Imagem (placeholder por enquanto)
	setup_card_image(card)

func setup_attributes(card: Card):
	var attribute_labels = [
		strength_label, density_label, power_weight_label, biomech_label,
		material_label, accel_label, pressure_label, metabolic_label
	]
	
	var attribute_values = card.get_attributes_array()
	var attribute_names = card.get_attribute_names()
	
	for i in range(min(attribute_labels.size(), attribute_values.size())):
		if attribute_labels[i]:
			var short_name = attribute_names[i].split(" ")[1] if attribute_names[i].contains(" ") else attribute_names[i]
			attribute_labels[i].text = "%s: %d" % [short_name, attribute_values[i]]

func setup_info_labels(card: Card):
	if habitat_label:
		habitat_label.text = "🏡 " + card.habitat
	
	if conservation_label:
		conservation_label.text = "🛡️ " + card.conservation_status
		# Colorir baseado no status
		match card.conservation_status.to_lower():
			"pouco preocupante":
				conservation_label.modulate = Color.GREEN
			"quase ameaçada", "vulnerável":
				conservation_label.modulate = Color.YELLOW
			"em perigo":
				conservation_label.modulate = Color.ORANGE
			"criticamente em perigo":
				conservation_label.modulate = Color.RED
			_:
				conservation_label.modulate = Color.WHITE
	
	if photographer_label:
		photographer_label.text = "📸 " + card.photographer
	
	if power_total_label:
		power_total_label.text = "⚡ Poder Total: %d" % card.get_total_power()

func setup_rarity_visual(card: Card):
	# Cor do background baseada na raridade
	if background:
		background.color = card.get_rarity_color()
		
		# Ajustar opacidade para não ofuscar o conteúdo
		var rarity_color = card.get_rarity_color()
		rarity_color.a = 0.3
		background.color = rarity_color
	
	# Ícone de raridade (placeholder)
	if rarity_icon:
		# Por enquanto, apenas colorir
		var rarity_info = card.get_visual_rarity_info()
		rarity_icon.modulate = card.get_rarity_color()
		rarity_icon.tooltip_text = rarity_info["name"]

func setup_card_image(card: Card):
	if not card_image:
		return
	
	# Tentar carregar imagem real
	if card.artwork_path != "" and FileAccess.file_exists(card.artwork_path):
		var texture = load(card.artwork_path)
		if texture:
			card_image.texture = texture
			return
	
	# Placeholder se não encontrar imagem
	create_placeholder_image(card)

func create_placeholder_image(card: Card):
	# Criar uma imagem placeholder colorida
	var image = Image.create(200, 150, false, Image.FORMAT_RGB8)
	
	# Cor baseada na espécie (hash do nome)
	var color_seed = card.species_id.hash()
	var r = float((color_seed >> 16) & 0xFF) / 255.0
	var g = float((color_seed >> 8) & 0xFF) / 255.0
	var b = float(color_seed & 0xFF) / 255.0
	
	image.fill(Color(r * 0.7, g * 0.7, b * 0.7))  # Cor suavizada
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	card_image.texture = texture

# ===== INTERAÇÕES =====

func _on_mouse_entered():
	if scale_on_hover:
		create_tween().tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	
	card_hovered.emit(card_data)

func _on_mouse_exited():
	if scale_on_hover:
		create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			card_clicked.emit(card_data)
			print("🔍 Carta clicada: %s" % card_data.name)

# ===== UTILITÁRIOS PÚBLICOS =====

func set_interactive(interactive: bool):
	is_interactive = interactive
	mouse_filter = Control.MOUSE_FILTER_IGNORE if not interactive else Control.MOUSE_FILTER_PASS

func set_scale_hover(enable: bool):
	scale_on_hover = enable

# Redimensiona a carta
func set_card_size(new_size: Vector2):
	custom_minimum_size = new_size
	size = new_size

# Para debug
func print_card_info():
	if card_data:
		print("🃏 CardDisplay - %s (%s)" % [card_data.name, card_data.species_id])
		print("   Raridade: %s" % CardGenerator.get_rarity_name(card_data.visual_rarity))
		print("   Poder: %d" % card_data.get_total_power())
