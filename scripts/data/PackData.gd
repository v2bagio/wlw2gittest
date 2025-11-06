extends Resource
class_name PackData

@export var pack_id: String = ""
@export var pack_name: String = ""
@export var theme: String = ""                  # Ex: "Mamíferos Brasileiros"
@export var release_month: String = ""
@export var total_species: int = 8              # 8 cartas por pacote
@export var guaranteed_rare_count: int = 2      # 1-2 cartas raras garantidas
@export var cost_coins: int = 250

# Lista de espécies neste pacote
@export var species_list: Array[String] = []

# Lista de fotógrafos participantes
@export var photographers: Array[String] = []

# Probabilidades de raridade
@export var rarity_weights: Dictionary = {
	Card.ArtRarity.NORMAL: 0.70,
	Card.ArtRarity.HOLOGRAPHIC: 0.20,
	Card.ArtRarity.FULL_ART: 0.08,
	Card.ArtRarity.HOLO_FULL_ART: 0.02
}

func get_random_art_rarity() -> Card.ArtRarity:
	var roll = randf()
	var cumulative = 0.0
	
	for rarity in rarity_weights:
		cumulative += rarity_weights[rarity]
		if roll <= cumulative:
			return rarity
			
	var test_pack = PackData.new()
	test_pack.pack_id = "teste"
	test_pack.cost_coins = 200   # Isso funciona, pois cost_coins está definido!

	return Card.ArtRarity.NORMAL
