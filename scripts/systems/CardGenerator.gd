extends Node
class_name CardGenerator

# Dados de fotógrafos fictícios para teste
static var _photographers: Array[Dictionary] = [
	{"name": "Carlos Silva", "specialty": "Amazônia", "style": "Wildlife"},
	{"name": "Marina Santos", "specialty": "Mata Atlântica", "style": "Macro"},
	{"name": "João Pereira", "specialty": "Cerrado", "style": "Landscape"},
	{"name": "Ana Costa", "specialty": "Pantanal", "style": "Action"},
	{"name": "Pedro Lima", "specialty": "Caatinga", "style": "Portrait"}
]

# Pesos para raridade visual
static var _visual_rarity_weights: Dictionary = {
	Card.ArtRarity.NORMAL: 70.0,
	Card.ArtRarity.HOLOGRAPHIC: 20.0,
	Card.ArtRarity.FULL_ART: 8.0,
	Card.ArtRarity.HOLO_FULL_ART: 2.0
}

# ===== GERAÇÃO DE CARTA INDIVIDUAL =====

static func generate_card(species_id: String, pack_info: Dictionary = {}) -> Card:
	print("🎨 Gerando carta para espécie: %s" % species_id)
	
	# 1. Criar carta base com dados científicos
	var card = Card.create_from_species(species_id, pack_info)
	if card == null:
		print("❌ Falha ao criar carta base para %s" % species_id)
		return null
	
	# 2. Adicionar sistema de arte
	add_artwork_data(card)
	
	# 3. Definir raridade visual
	assign_visual_rarity(card)
	
	print("✅ Carta gerada: %s (%s)" % [card.name, get_rarity_name(card.visual_rarity)])
	return card

static func generate_card_with_rarity(species_id: String, visual_rarity: Card.ArtRarity, pack_info: Dictionary = {}) -> Card:
	var card = generate_card(species_id, pack_info)
	if card:
		card.visual_rarity = visual_rarity
		regenerate_ids_after_rarity_change(card)
	return card

# ===== SISTEMA DE ARTE =====

static func add_artwork_data(card: Card):
	var photographer = get_random_photographer(card.habitat)
	var artwork_number = randi() % 5 + 1  # 5 artes possíveis por animal
	
	card.artwork_id = "%s_art_%03d" % [card.species_id.to_lower(), artwork_number]
	card.artwork_path = "res://assets/images/cards/%s/%s_%03d.png" % [card.species_id.to_lower(), card.species_id.to_lower(), artwork_number]
	card.photographer = photographer["name"]
	card.photography_location = get_photography_location(card.habitat)

static func get_random_photographer(habitat: String) -> Dictionary:
	var suitable_photographers = []
	
	for photographer in _photographers:
		if habitat.to_lower().contains(photographer["specialty"].to_lower()):
			suitable_photographers.append(photographer)
	
	if suitable_photographers.is_empty():
		suitable_photographers = _photographers
	
	return suitable_photographers[randi() % suitable_photographers.size()]

# ✅ CORRIGIDO: Removido parâmetro não usado
static func get_photography_location(habitat: String) -> String:
	var locations = {
		"Amazônia": ["Manaus, AM", "Belém, PA", "Rio Negro, AM", "Tapajós, PA"],
		"Mata Atlântica": ["Serra do Mar, SP", "Tijuca, RJ", "Itatiaia, RJ", "Iguaçu, PR"],
		"Cerrado": ["Chapada dos Veadeiros, GO", "Pantanal, MT", "Brasília, DF", "Jalapão, TO"],
		"Pantanal": ["Corumbá, MS", "Poconé, MT", "Miranda, MS", "Aquidauana, MS"],
		"Caatinga": ["Serra da Capivara, PI", "Chapada Diamantina, BA", "Cariri, CE", "Sertão, PE"]
	}
	
	for habitat_key in locations.keys():
		if habitat.to_lower().contains(habitat_key.to_lower()):
			var location_list = locations[habitat_key]
			return location_list[randi() % location_list.size()]
	
	return "Brasil"

# ===== SISTEMA DE RARIDADE VISUAL =====

static func assign_visual_rarity(card: Card, forced_rare: bool = false):
	if forced_rare:
		card.visual_rarity = get_forced_rare_rarity()
	else:
		card.visual_rarity = get_weighted_visual_rarity()

static func get_weighted_visual_rarity() -> Card.ArtRarity:
	var total_weight = 0.0
	for weight in _visual_rarity_weights.values():
		total_weight += weight
	
	var roll = randf() * total_weight
	var cumulative = 0.0
	
	for rarity in _visual_rarity_weights:
		cumulative += _visual_rarity_weights[rarity]
		if roll <= cumulative:
			return rarity
	
	return Card.ArtRarity.NORMAL

static func get_forced_rare_rarity() -> Card.ArtRarity:
	var rare_options = [Card.ArtRarity.HOLOGRAPHIC, Card.ArtRarity.FULL_ART]
	if randf() < 0.2:
		return Card.ArtRarity.HOLO_FULL_ART
	
	return rare_options[randi() % rare_options.size()]

static func regenerate_ids_after_rarity_change(card: Card):
	card.generate_unique_id()
	card.generate_serial_number()
	card.generate_verification_hash()

# ===== GERAÇÃO DE PACOTES (CORRIGIDA) =====

static func generate_pack(pack_data: PackData) -> Array[Card]:
	if not AnimalDatabase.load_database():
		print("❌ Não foi possível carregar database de animais")
		return []
	
	print("📦 Gerando pacote: %s (%d cartas)" % [pack_data.pack_name, pack_data.total_species])
	
	var cards: Array[Card] = []
	var available_species = AnimalDatabase.get_all_species_ids()
	
	if available_species.size() == 0:
		print("❌ Nenhuma espécie disponível na database!")
		return []
	
	print("   🦎 %d espécies disponíveis na database" % available_species.size())
	
	# ✅ NOVO: Permitir espécies duplicadas com artes diferentes
	available_species.shuffle()
	
	var pack_info = {
		"pack_id": pack_data.pack_id,
		"pack_name": pack_data.pack_name,
		"release_month": pack_data.release_month
	}
	
	var rare_cards_generated = 0
	var guaranteed_rare_count = pack_data.guaranteed_rare_count
	
	for i in range(pack_data.total_species):
		# ✅ PERMITIR DUPLICATAS: Usar módulo para repetir espécies se necessário
		var species_id = available_species[i % available_species.size()]
		
		# Determinar se esta carta deve ser rara (garantida)
		var force_rare = (rare_cards_generated < guaranteed_rare_count)
		
		print("   🎨 Gerando carta %d/%d: %s" % [i + 1, pack_data.total_species, species_id])
		
		var card = generate_card(species_id, pack_info)
		if card:
			card.card_number_in_pack = i + 1
			
			# Aplicar raridade forçada se necessário
			if force_rare:
				assign_visual_rarity(card, true)
				rare_cards_generated += 1
				print("      🌟 Carta rara garantida: %s (%s)" % [card.name, get_rarity_name(card.visual_rarity)])
			
			cards.append(card)
		else:
			print("      ❌ Falha ao gerar carta para %s" % species_id)
	
	print("✅ Pacote gerado: %d cartas (%d raras)" % [cards.size(), rare_cards_generated])
	print("   📊 Distribuição de espécies:")
	count_species_distribution(cards)
	
	return cards

# ===== NOVA FUNÇÃO: ANÁLISE DE DISTRIBUIÇÃO =====

static func count_species_distribution(cards: Array[Card]):
	var species_count: Dictionary = {}
	
	for card in cards:
		if species_count.has(card.species_id):
			species_count[card.species_id] += 1
		else:
			species_count[card.species_id] = 1
	
	for species_id in species_count:
		var count = species_count[species_id]
		var species = AnimalDatabase.get_species(species_id)
		var species_name = species.name if species else species_id
		
		if count > 1:
			print("      🎨 %s: %d cartas (artes diferentes)" % [species_name, count])
		else:
			print("      🦎 %s: %d carta" % [species_name, count])

# ===== UTILITÁRIOS =====

static func get_rarity_name(rarity: Card.ArtRarity) -> String:
	match rarity:
		Card.ArtRarity.NORMAL:
			return "Normal"
		Card.ArtRarity.HOLOGRAPHIC:
			return "Holográfica"
		Card.ArtRarity.FULL_ART:
			return "Full Art"
		Card.ArtRarity.HOLO_FULL_ART:
			return "Holo Full Art"
	return "Desconhecida"

# ✅ CORRIGIDO: Agora usa sua PackData.gd
static func create_test_pack() -> PackData:
	var pack = PackData.new()
	pack.pack_id = "mamiferos_br_001"
	pack.pack_name = "Mamíferos Brasileiros"
	pack.theme = "Mamíferos do Brasil"
	pack.release_month = "2026-01"
	pack.total_species = 8
	pack.guaranteed_rare_count = 2
	
	return pack

static func get_generation_stats(cards: Array[Card]) -> Dictionary:
	var stats = {
		"total": cards.size(),
		"by_rarity": {},
		"photographers": {},
		"power_average": 0.0
	}
	
	var total_power = 0
	
	for card in cards:
		var rarity_name = get_rarity_name(card.visual_rarity)
		if stats["by_rarity"].has(rarity_name):
			stats["by_rarity"][rarity_name] += 1
		else:
			stats["by_rarity"][rarity_name] = 1
		
		if stats["photographers"].has(card.photographer):
			stats["photographers"][card.photographer] += 1
		else:
			stats["photographers"][card.photographer] = 1
		
		total_power += card.get_total_power()
	
	if cards.size() > 0:
		stats["power_average"] = float(total_power) / cards.size()
	
	return stats

static func print_generation_stats(cards: Array[Card]):
	var stats = get_generation_stats(cards)
	
	print("\n📊 ===== ESTATÍSTICAS DE GERAÇÃO =====")
	print("   Total de cartas: %d" % stats["total"])
	print("   Poder médio: %.1f" % stats["power_average"])
	
	print("\n🎨 Por raridade:")
	for rarity in stats["by_rarity"]:
		print("   %s: %d cartas" % [rarity, stats["by_rarity"][rarity]])
	
	print("\n📸 Por fotógrafo:")
	for photographer in stats["photographers"]:
		print("   %s: %d cartas" % [photographer, stats["photographers"][photographer]])
