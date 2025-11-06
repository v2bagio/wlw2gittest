extends Resource
class_name Player

# ===== IDENTIFICAÇÃO =====
@export var player_id: String = ""
@export var username: String = ""
@export var email: String = ""
@export var level: int = 1
@export var experience: int = 0

# ===== RECURSOS =====
@export var coins: int = 1000          # Moedas básicas
@export var gems: int = 50             # Moedas premium
@export var dust: int = 0              # Pó para criar cartas (futuro)

# ===== COLEÇÃO =====
@export var collection: Array[Card] = []        # Todas as cartas do jogador
@export var favorite_cards: Array[String] = []  # IDs das cartas favoritas
@export var deck: Array[Card] = []               # Deck atual (max 30 cartas)

# ===== ESTATÍSTICAS =====
@export var total_packs_opened: int = 0
@export var total_battles_played: int = 0
@export var total_battles_won: int = 0
@export var rare_cards_collected: int = 0

# ===== PROGRESSÃO =====
@export var achievements: Array[String] = []    # IDs de conquistas desbloqueadas
@export var daily_login_streak: int = 0
@export var last_login_date: String = ""

# ===== CONFIGURAÇÕES =====
@export var settings: Dictionary = {
	"auto_save": true,
	"sound_effects": true,
	"music": true,
	"card_animations": true
}

# ===== MÉTODOS DE RECURSOS =====

func add_coins(amount: int) -> bool:
	if amount < 0:
		return remove_coins(-amount)
	
	coins += amount
	print("💰 +%d moedas. Total: %d" % [amount, coins])
	return true

func remove_coins(amount: int) -> bool:
	if amount <= 0:
		return false
	
	if coins >= amount:
		coins -= amount
		print("💸 -%d moedas. Total: %d" % [amount, coins])
		return true
	else:
		print("❌ Moedas insuficientes: %d necessárias, %d disponíveis" % [amount, coins])
		return false

func add_gems(amount: int) -> bool:
	if amount < 0:
		return remove_gems(-amount)
	
	gems += amount
	print("💎 +%d gemas. Total: %d" % [amount, gems])
	return true

func remove_gems(amount: int) -> bool:
	if amount <= 0:
		return false
	
	if gems >= amount:
		gems -= amount
		print("💎 -%d gemas. Total: %d" % [amount, gems])
		return true
	else:
		print("❌ Gemas insuficientes: %d necessárias, %d disponíveis" % [amount, gems])
		return false

# ===== MÉTODOS DE COLEÇÃO =====

func add_card_to_collection(card: Card) -> bool:
	if not card:
		print("❌ Tentativa de adicionar carta nula à coleção")
		return false
	
	collection.append(card)
	print("🃏 Carta adicionada à coleção: %s" % card.name)
	
	# Atualizar estatísticas
	update_collection_stats(card)
	return true

func add_cards_to_collection(cards: Array[Card]) -> int:
	var added_count = 0
	for card in cards:
		if add_card_to_collection(card):
			added_count += 1
	
	print("📦 %d cartas adicionadas à coleção" % added_count)
	return added_count

func update_collection_stats(card: Card):
	# Contar cartas raras
	if card.visual_rarity != Card.ArtRarity.NORMAL:
		rare_cards_collected += 1

func get_collection_by_rarity(rarity: Card.ArtRarity) -> Array[Card]:
	var filtered_cards: Array[Card] = []
	
	for card in collection:
		if card.visual_rarity == rarity:
			filtered_cards.append(card)
	
	return filtered_cards

func get_collection_by_species(species_id: String) -> Array[Card]:
	var filtered_cards: Array[Card] = []
	
	for card in collection:
		if card.species_id == species_id:
			filtered_cards.append(card)
	
	return filtered_cards

func get_total_collection_power() -> int:
	var total = 0
	for card in collection:
		total += card.get_total_power()
	return total

# ===== MÉTODOS DE DECK =====

func add_card_to_deck(card: Card) -> bool:
	if deck.size() >= 30:
		print("❌ Deck cheio! Máximo de 30 cartas")
		return false
	
	if not collection.has(card):
		print("❌ Carta não está na coleção do jogador")
		return false
	
	deck.append(card)
	print("🎴 Carta adicionada ao deck: %s (%d/30)" % [card.name, deck.size()])
	return true

func remove_card_from_deck(card: Card) -> bool:
	if deck.has(card):
		deck.erase(card)
		print("🗑️ Carta removida do deck: %s (%d/30)" % [card.name, deck.size()])
		return true
	
	return false

func clear_deck():
	deck.clear()
	print("🧹 Deck limpo")

func is_deck_valid() -> bool:
	return deck.size() >= 20  # Mínimo de 20 cartas para batalha

# ===== SISTEMA DE EXPERIÊNCIA =====

func add_experience(amount: int):
	experience += amount
	check_level_up()
	print("⭐ +%d XP. Total: %d (Nível %d)" % [amount, experience, level])

func check_level_up():
	var required_xp = get_required_xp_for_level(level + 1)
	
	while experience >= required_xp:
		level_up()
		required_xp = get_required_xp_for_level(level + 1)

func level_up():
	level += 1
	var reward_coins = level * 100
	var reward_gems = level * 5
	
	add_coins(reward_coins)
	add_gems(reward_gems)
	
	print("🎉 LEVEL UP! Nível %d alcançado!" % level)
	print("   Recompensa: %d moedas + %d gemas" % [reward_coins, reward_gems])

func get_required_xp_for_level(target_level: int) -> int:
	# Fórmula: 100 * level^1.5
	return int(100 * pow(target_level, 1.5))

# ===== MÉTODOS DE ESTATÍSTICAS =====

func get_collection_stats() -> Dictionary:
	var stats = {
		"total_cards": collection.size(),
		"unique_species": get_unique_species_count(),
		"by_rarity": {},
		"total_power": get_total_collection_power(),
		"favorite_count": favorite_cards.size()
	}
	
	# Contar por raridade
	for rarity in Card.ArtRarity.values():
		var count = get_collection_by_rarity(rarity).size()
		stats["by_rarity"][CardGenerator.get_rarity_name(rarity)] = count
	
	return stats

func get_unique_species_count() -> int:
	var unique_species: Array[String] = []
	
	for card in collection:
		if not unique_species.has(card.species_id):
			unique_species.append(card.species_id)
	
	return unique_species.size()

func get_win_rate() -> float:
	if total_battles_played == 0:
		return 0.0
	
	return float(total_battles_won) / float(total_battles_played)

# ===== SISTEMA DE FAVORITOS =====

func add_to_favorites(card: Card) -> bool:
	if not collection.has(card):
		return false
	
	if not favorite_cards.has(card.unique_id):
		favorite_cards.append(card.unique_id)
		print("⭐ Carta adicionada aos favoritos: %s" % card.name)
		return true
	
	return false

func remove_from_favorites(card: Card) -> bool:
	if favorite_cards.has(card.unique_id):
		favorite_cards.erase(card.unique_id)
		print("⭐ Carta removida dos favoritos: %s" % card.name)
		return true
	
	return false

func get_favorite_cards() -> Array[Card]:
	var favorites: Array[Card] = []
	
	for card in collection:
		if favorite_cards.has(card.unique_id):
			favorites.append(card)
	
	return favorites

# ===== VALIDAÇÃO E DEBUG =====

func is_valid() -> bool:
	return (player_id != "" and username != "" and 
			coins >= 0 and gems >= 0 and level > 0)

func print_player_summary():
	print("\n👤 ===== RESUMO DO JOGADOR =====")
	print("   🆔 %s (%s)" % [username, player_id])
	print("   ⭐ Nível %d (%d XP)" % [level, experience])
	print("   💰 %d moedas | 💎 %d gemas" % [coins, gems])
	print("   🃏 %d cartas na coleção" % collection.size())
	print("   🎴 %d cartas no deck" % deck.size())
	print("   🏆 %d vitórias / %d batalhas (%.1f%%)" % [total_battles_won, total_battles_played, get_win_rate() * 100])
	print("   📦 %d pacotes abertos" % total_packs_opened)

func print_collection_summary():
	var stats = get_collection_stats()
	
	print("\n🃏 ===== RESUMO DA COLEÇÃO =====")
	print("   Total: %d cartas" % stats["total_cards"])
	print("   Espécies únicas: %d" % stats["unique_species"])
	print("   Poder total: %d" % stats["total_power"])
	print("   Favoritas: %d" % stats["favorite_count"])
	
	print("\n   Por raridade:")
	for rarity_name in stats["by_rarity"]:
		print("   - %s: %d cartas" % [rarity_name, stats["by_rarity"][rarity_name]])

# ===== SISTEMA DE SALVAMENTO (PREPARAÇÃO) =====

func to_save_data() -> Dictionary:
	# Converter dados do jogador para Dictionary (para salvar em arquivo)
	return {
		"player_id": player_id,
		"username": username,
		"email": email,
		"level": level,
		"experience": experience,
		"coins": coins,
		"gems": gems,
		"dust": dust,
		"collection_size": collection.size(),
		"total_packs_opened": total_packs_opened,
		"total_battles_played": total_battles_played,
		"total_battles_won": total_battles_won,
		"settings": settings
	}
