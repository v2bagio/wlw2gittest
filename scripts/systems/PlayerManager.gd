extends Node

var current_player: Player = null
var is_logged_in: bool = false

# ===== INICIALIZAÇÃO =====

func _ready():
	print("👤 PlayerManager inicializado")

# ===== MÉTODOS DE LOGIN/LOGOUT =====

func create_new_player(username: String, email: String = "") -> Player:
	var player = Player.new()
	player.player_id = generate_player_id()
	player.username = username
	player.email = email
	player.last_login_date = Time.get_datetime_string_from_system()
	
	# Dar cartas iniciais
	give_starter_pack(player)
	
	print("🎉 Novo jogador criado: %s" % username)
	return player

func login_player(player: Player) -> bool:
	if not player or not player.is_valid():
		print("❌ Dados de jogador inválidos")
		return false
	
	current_player = player
	is_logged_in = true
	
	# Atualizar login streak
	update_daily_login()
	
	print("✅ Jogador logado: %s (Nível %d)" % [player.username, player.level])
	return true

func logout_player():
	if current_player:
		print("👋 Jogador deslogado: %s" % current_player.username)
	
	current_player = null
	is_logged_in = false

# ===== MÉTODOS DE ACESSO =====

func get_current_player() -> Player:
	return current_player

func is_player_logged_in() -> bool:
	return is_logged_in and current_player != null

# ===== MÉTODOS DE CONVENIÊNCIA =====

func get_player_coins() -> int:
	return current_player.coins if current_player else 0

func get_player_gems() -> int:
	return current_player.gems if current_player else 0

func get_player_collection() -> Array[Card]:
	return current_player.collection if current_player else []

func buy_pack_with_coins(pack_data: PackData) -> Array[Card]:
	if not current_player:
		print("❌ Nenhum jogador logado")
		return []
	
	if not current_player.remove_coins(pack_data.cost_coins):
		return []  # Não tem moedas suficientes
	
	# Gerar pacote
	var cards = CardGenerator.generate_pack(pack_data)
	
	# Adicionar à coleção
	current_player.add_cards_to_collection(cards)
	current_player.total_packs_opened += 1
	
	# Dar XP
	current_player.add_experience(50)
	
	print("🎁 Pacote comprado e cartas adicionadas à coleção!")
	return cards

# ===== SISTEMA DE STARTER PACK =====

func give_starter_pack(player: Player):
	print("🎁 Dando cartas iniciais...")
	
	# Criar um pacote inicial gratuito
	var starter_pack = PackData.new()
	starter_pack.pack_id = "starter_pack"
	starter_pack.pack_name = "Pacote Inicial"
	starter_pack.total_species = 5
	starter_pack.guaranteed_rare_count = 1
	
	var starter_cards = CardGenerator.generate_pack(starter_pack)
	player.add_cards_to_collection(starter_cards)
	
	print("✅ %d cartas iniciais adicionadas" % starter_cards.size())

# ===== UTILITÁRIOS =====

func generate_player_id() -> String:
	var timestamp = Time.get_unix_time_from_system()
	var random_suffix = randi() % 10000
	return "YGG_%d_%04d" % [timestamp, random_suffix]

func update_daily_login():
	if not current_player:
		return
	
	var today = Time.get_date_string_from_system()
	
	if current_player.last_login_date != today:
		current_player.daily_login_streak += 1
		current_player.last_login_date = today
		
		# Recompensa por login diário
		var bonus_coins = current_player.daily_login_streak * 10
		current_player.add_coins(bonus_coins)
		
		print("🎉 Login diário! Streak: %d (+%d moedas)" % [current_player.daily_login_streak, bonus_coins])
