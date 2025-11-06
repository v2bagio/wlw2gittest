extends Resource
class_name Card

# ===== IDENTIFICAÇÃO E SEGURANÇA =====
@export var unique_id: String = ""              # ID único criptográfico da carta
@export var card_serial: String = ""            # Número serial para segurança
@export var verification_hash: String = ""      # Hash para verificação de autenticidade

# ===== DADOS DA ESPÉCIE =====
@export var species_id: String = ""             # ID da espécie (ex: "jaguar")
@export var name: String = ""                   # Nome da carta
@export var species_name: String = ""           # Nome científico
@export var habitat: String = ""                # Habitat natural
@export var conservation_status: String = ""    # Status de conservação IUCN
@export var description: String = ""            # Descrição educativa

# ===== SISTEMA DE PACOTE E LANÇAMENTO =====
@export var pack_id: String = ""                # ID do pacote (ex: "mamiferos_br_001")
@export var pack_name: String = ""              # Nome do pacote (ex: "Mamíferos Brasileiros")
@export var release_month: String = ""          # Mês/ano de lançamento (ex: "2026-01")
@export var card_number_in_pack: int = 0        # Número da carta no pacote (1-8)

# ===== SISTEMA DE ARTE E RARIDADE VISUAL =====
@export var artwork_id: String = ""             # ID específico desta arte
@export var artwork_path: String = ""           # Caminho para a imagem
@export var photographer: String = ""           # Nome do fotógrafo/artista
@export var photography_location: String = ""   # Local onde foi fotografada
@export var art_style: String = "normal"        # normal, holographic, full_art, holo_full_art

# ===== RARIDADES VISUAIS =====
enum ArtRarity {
	NORMAL,           # Arte comum com bordas
	HOLOGRAPHIC,      # Arte holográfica
	FULL_ART,         # Full art sem bordas
	HOLO_FULL_ART     # Holográfica + Full art (ultra rara)
}

@export var visual_rarity: ArtRarity = ArtRarity.NORMAL

# ===== ATRIBUTOS CIENTÍFICOS (SISTEMA D BALANCEADO) =====
@export var strength_relative: int = 0         # Força Relativa ao peso corporal
@export var structural_density: int = 0        # Densidade Estrutural (resistência óssea/muscular)
@export var power_per_weight: int = 0          # Potência por Quilograma
@export var biomech_efficiency: int = 0        # Eficiência Biomecânica do movimento
@export var material_resistance: int = 0       # Resistência de materiais corporais
@export var acceleration_capacity: int = 0     # Capacidade de Aceleração
@export var pressure_resistance: int = 0       # Resistência à Pressão
@export var metabolic_power: int = 0           # Potência Metabólica

# ===== MÉTODOS DE IDENTIFICAÇÃO E SEGURANÇA =====

# Gera um ID único baseado em timestamp, hash e dados da carta
func generate_unique_id() -> String:
	var data_string = "%s_%s_%s_%s_%d" % [
		species_id, pack_id, photographer, artwork_id, Time.get_unix_time_from_system()
	]
	var hashs = data_string.md5_text()
	unique_id = "YGG_%s_%s" % [species_id.to_upper(), hashs.substr(0, 8)]
	return unique_id

# Gera número serial para rastreamento
func generate_serial_number() -> String:
	var timestamp = Time.get_unix_time_from_system()
	var random_suffix = str(randi() % 10000).pad_zeros(4)
	card_serial = "WLD%d%s" % [timestamp, random_suffix]
	return card_serial

# Gera hash de verificação baseado em todos os dados da carta
func generate_verification_hash() -> String:
	var all_data = str([
		unique_id, species_id, pack_id, photographer, 
		get_attributes_array(), visual_rarity
	])
	verification_hash = all_data.sha256_text().substr(0, 16)
	return verification_hash

# Verifica se a carta é autêntica comparando hash
func verify_authenticity(expected_hash: String = "") -> bool:
	if expected_hash == "":
		expected_hash = verification_hash
	var current_hash = generate_verification_hash()
	return current_hash == expected_hash

# ===== MÉTODOS DE RARIDADE E VISUAL =====

# Retorna informações da raridade visual
func get_visual_rarity_info() -> Dictionary:
	match visual_rarity:
		ArtRarity.NORMAL:
			return {
				"name": "Normal",
				"description": "Arte padrão com bordas e frames",
				"foil": false,
				"full_art": false,
				"pull_rate": 0.80
			}
		ArtRarity.HOLOGRAPHIC:
			return {
				"name": "Holográfica", 
				"description": "Arte com efeito holográfico",
				"foil": true,
				"full_art": false,
				"pull_rate": 0.15
			}
		ArtRarity.FULL_ART:
			return {
				"name": "Full Art",
				"description": "Arte sem bordas ocupando todo o cartão",
				"foil": false,
				"full_art": true,
				"pull_rate": 0.04
			}
		ArtRarity.HOLO_FULL_ART:
			return {
				"name": "Holográfica Full Art",
				"description": "Arte holográfica sem bordas (ultra rara)",
				"foil": true,
				"full_art": true,
				"pull_rate": 0.01
			}
	return {}

# Retorna cor da raridade para UI
func get_rarity_color() -> Color:
	match visual_rarity:
		ArtRarity.NORMAL:
			return Color.WHITE
		ArtRarity.HOLOGRAPHIC:
			return Color.CYAN
		ArtRarity.FULL_ART:
			return Color.GOLD
		ArtRarity.HOLO_FULL_ART:
			return Color.MAGENTA
	return Color.WHITE

# ===== MÉTODOS DE ATRIBUTOS (INALTERADOS) =====

func get_attributes_array() -> Array[int]:
	return [strength_relative, structural_density, power_per_weight,
			biomech_efficiency, material_resistance, acceleration_capacity,
			pressure_resistance, metabolic_power]

func get_attribute_names() -> Array[String]:
	return ["🔥 Força Relativa", "🏗️ Densidade Estrutural", "⚡ Potência/Peso",
			"🎯 Eficiência Biomecânica", "🛡️ Resistência Material", "🚀 Aceleração",
			"💎 Resistência Pressão", "⚙️ Potência Metabólica"]

func get_total_power() -> int:
	var total = 0
	for attribute in get_attributes_array():
		total += attribute
	return total

# ===== MÉTODOS DE INFORMAÇÃO =====

func get_pack_info() -> Dictionary:
	return {
		"pack_id": pack_id,
		"pack_name": pack_name,
		"release_month": release_month,
		"card_position": card_number_in_pack
	}

func get_photographer_info() -> Dictionary:
	return {
		"name": photographer,
		"location": photography_location,
		"artwork_id": artwork_id
	}

# ===== VALIDAÇÃO E DEBUG =====

func is_valid() -> bool:
	return (unique_id != "" and species_id != "" and pack_id != "" 
			and photographer != "" and card_serial != "")

func print_detailed_info():
	print("🃏 ===== WILDLIFE CARD =====")
	print("   🔢 ID Único: %s" % unique_id)
	print("   📋 Serial: %s" % card_serial)
	print("   🦎 Espécie: %s (%s)" % [name, species_name])
	print("   📦 Pacote: %s (%s)" % [pack_name, release_month])
	print("   📸 Fotógrafo: %s" % photographer)
	print("   🎨 Raridade Visual: %s" % get_visual_rarity_info()["name"])
	print("   ⚡ Poder Total: %d" % get_total_power())
	print("   🔐 Hash Verificação: %s" % verification_hash)
	print("   ✅ Válida: %s" % is_valid())

# Carrega dados científicos da database
func load_species_data() -> bool:
	var species_data = AnimalDatabase.get_species(species_id)
	
	if species_data == null:
		print("❌ Dados científicos não encontrados para: %s" % species_id)
		return false
	
	# Copiar dados científicos
	name = species_data.name
	species_name = species_data.species_name
	habitat = species_data.habitat
	conservation_status = species_data.conservation_status
	description = species_data.description
	
	# Copiar atributos
	strength_relative = species_data.strength_relative
	structural_density = species_data.structural_density
	power_per_weight = species_data.power_per_weight
	biomech_efficiency = species_data.biomech_efficiency
	material_resistance = species_data.material_resistance
	acceleration_capacity = species_data.acceleration_capacity
	pressure_resistance = species_data.pressure_resistance
	metabolic_power = species_data.metabolic_power
	
	return true

# Construtor simplificado
@warning_ignore("shadowed_variable")
static func create_from_species(species_id: String, pack_info: Dictionary = {}) -> Card:
	var card = Card.new()
	card.species_id = species_id
	
	# Carregar dados científicos
	if not card.load_species_data():
		return null
	
	# Definir dados do pacote
	if pack_info.has("pack_id"):
		card.pack_id = pack_info["pack_id"]
		card.pack_name = pack_info["pack_name"]
		card.release_month = pack_info["release_month"]
	
	# Gerar IDs de segurança
	card.generate_unique_id()
	card.generate_serial_number()
	card.generate_verification_hash()
	
	return card
	

func duplicate_card() -> Card:
	var new_card = Card.new()
	
	# Copiar dados básicos (NOVO ID será gerado)
	new_card.species_id = species_id
	new_card.name = name
	new_card.species_name = species_name
	new_card.habitat = habitat
	new_card.conservation_status = conservation_status
	new_card.description = description
	
	# Copiar dados do pacote
	new_card.pack_id = pack_id
	new_card.pack_name = pack_name
	new_card.release_month = release_month
	new_card.card_number_in_pack = card_number_in_pack
	
	# Copiar dados de arte
	new_card.artwork_id = artwork_id
	new_card.artwork_path = artwork_path
	new_card.photographer = photographer
	new_card.photography_location = photography_location
	new_card.art_style = art_style
	new_card.visual_rarity = visual_rarity
	
	# Copiar atributos
	var attrs = get_attributes_array()
	new_card.strength_relative = attrs[0]
	new_card.structural_density = attrs[1]
	new_card.power_per_weight = attrs[2]
	new_card.biomech_efficiency = attrs[3]
	new_card.material_resistance = attrs[4]
	new_card.acceleration_capacity = attrs[5]
	new_card.pressure_resistance = attrs[6]
	new_card.metabolic_power = attrs[7]
	
	# Gerar novos IDs de segurança
	new_card.generate_unique_id()
	new_card.generate_serial_number()
	new_card.generate_verification_hash()
	
	return new_card
