extends Node
class_name AnimalDatabase

# Cache dos dados carregados
static var _species_data: Dictionary = {}
static var _is_loaded: bool = false
static var _last_id_number: int = 0

# Estrutura de dados de uma espécie
class SpeciesData:
	var species_id: String = ""
	var name: String = ""
	var species_name: String = ""
	var habitat: String = ""
	var conservation_status: String = ""
	var description: String = ""
	
	# Atributos científicos
	var strength_relative: int = 0
	var structural_density: int = 0
	var power_per_weight: int = 0
	var biomech_efficiency: int = 0
	var material_resistance: int = 0
	var acceleration_capacity: int = 0
	var pressure_resistance: int = 0
	var metabolic_power: int = 0
	
	func get_id_number() -> int:
		var id_clean = species_id.replace("B", "")
		return int(id_clean)
	
	func print_info():
		print("   🆔 %s: %s (%s)" % [species_id, name, species_name])
		print("      🏡 %s | 🛡️ %s" % [habitat, conservation_status])
		print("      ⚡ Poder Total: %d" % get_total_power())
	
	func get_total_power() -> int:
		return (strength_relative + structural_density + power_per_weight + 
				biomech_efficiency + material_resistance + acceleration_capacity + 
				pressure_resistance + metabolic_power)

# Carrega a database do arquivo CSV
static func load_database(force_reload: bool = false) -> bool:
	if _is_loaded and not force_reload:
		return true
	print("db carregado")
	
	var file_path = "res://resources/animals_database.csv"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		print("deu ruim no %s" % file_path)
		print("conferir db em resources/")
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	if lines.size() < 2:
		print("❌ ERRO: CSV deve ter pelo menos cabeçalho + 1 linha")
		return false
	
	# Limpar cache
	_species_data.clear()
	_last_id_number = 0
	
	# Processar cabeçalho
	var headers = lines[0].split(",")
	print("📋 Colunas encontradas: %s" % str(headers))
	
	# Processar dados
	var loaded_count = 0
	for i in range(1, lines.size()):
		var line = lines[i].strip_edges()
		if line == "":
			continue
			
		var values = line.split(",")
		
		if values.size() != headers.size():
			print("⚠️  Linha %d ignorada: número incorreto de colunas (%d vs %d)" % 
				  [i + 1, values.size(), headers.size()])
			continue
		
		var species = SpeciesData.new()
		
		# Mapear cada coluna
		for j in range(headers.size()):
			var header = headers[j].strip_edges()
			var value = values[j].strip_edges()
			
			match header:
				"species_id":
					species.species_id = value
					var id_num = species.get_id_number()
					if id_num > _last_id_number:
						_last_id_number = id_num
				"name":
					species.name = value
				"species_name":
					species.species_name = value
				"habitat":
					species.habitat = value
				"conservation_status":
					species.conservation_status = value
				"description":
					species.description = value
				"strength_relative":
					species.strength_relative = max(0, int(value))
				"structural_density":
					species.structural_density = max(0, int(value))
				"power_per_weight":
					species.power_per_weight = max(0, int(value))
				"biomech_efficiency":
					species.biomech_efficiency = max(0, int(value))
				"material_resistance":
					species.material_resistance = max(0, int(value))
				"acceleration_capacity":
					species.acceleration_capacity = max(0, int(value))
				"pressure_resistance":
					species.pressure_resistance = max(0, int(value))
				"metabolic_power":
					species.metabolic_power = max(0, int(value))
		
		if species.species_id != "" and species.name != "":
			_species_data[species.species_id] = species
			loaded_count += 1
		else:
			print("⚠️  Linha %d ignorada: dados essenciais em branco" % (i + 1))
	
	_is_loaded = true
	print("✅ DATABASE CARREGADA: %d espécies" % loaded_count)
	print("🔢 Próximo ID disponível: B%03d" % (_last_id_number + 1))
	return true

# Obtém uma espécie específica
static func get_species(species_id: String) -> SpeciesData:
	if not _is_loaded:
		load_database()
	
	if _species_data.has(species_id):
		return _species_data[species_id]
	
	print("⚠️  Espécie não encontrada: %s" % species_id)
	return null

# Lista todos os IDs disponíveis
static func get_all_species_ids() -> Array[String]:
	if not _is_loaded:
		load_database()
	
	var keys = _species_data.keys()
	var ids: Array[String] = []
	ids.assign(keys)  # ← MÉTODO ASSIGN PARA ARRAYS TIPADOS
	ids.sort()
	return ids

# Busca por habitat
static func get_species_by_habitat(habitat_search: String) -> Array[SpeciesData]:
	if not _is_loaded:
		load_database()
	
	var results: Array[SpeciesData] = []
	for species_id in _species_data:
		var species = _species_data[species_id] as SpeciesData
		if species.habitat.to_lower().contains(habitat_search.to_lower()):
			results.append(species)
	
	return results

# Gera próximo ID disponível
static func generate_next_id() -> String:
	if not _is_loaded:
		load_database()
	
	_last_id_number += 1
	return "B%03d" % _last_id_number

# Estatísticas da database
static func get_stats() -> Dictionary:
	if not _is_loaded:
		load_database()
	
	var total = _species_data.size()
	var by_status = {}
	var by_habitat = {}
	
	for species_id in _species_data:
		var species = _species_data[species_id] as SpeciesData
		
		# Contar por status de conservação
		if by_status.has(species.conservation_status):
			by_status[species.conservation_status] += 1
		else:
			by_status[species.conservation_status] = 1
		
		# Contar por habitat principal
		var main_habitat = species.habitat.split(" ")[0]
		if by_habitat.has(main_habitat):
			by_habitat[main_habitat] += 1
		else:
			by_habitat[main_habitat] = 1
	
	return {
		"total_species": total,
		"last_id_number": _last_id_number,
		"by_conservation_status": by_status,
		"by_habitat": by_habitat
	}

# Debug completo
static func print_full_database():
	if not _is_loaded:
		load_database()
	
	print("\n🦎 ===== DB COMPLETA =====")
	
	# Estatísticas gerais
	var stats = get_stats()
	print("📊 ESTATÍSTICAS:")
	print("   Total de espécies: %d" % stats["total_species"])
	print("   Último ID: B%03d" % stats["last_id_number"])
	
	print("\n🛡️  POR STATUS DE CONSERVAÇÃO:")
	for status in stats["by_conservation_status"]:
		print("   %s: %d espécies" % [status, stats["by_conservation_status"][status]])
	
	print("\n🏡 POR HABITAT:")
	for habitat in stats["by_habitat"]:
		print("   %s: %d espécies" % [habitat, stats["by_habitat"][habitat]])
	
	print("\n📋 TODAS AS ESPÉCIES:")
	var sorted_ids = get_all_species_ids()
	for species_id in sorted_ids:
		var species = get_species(species_id)
		species.print_info()
	
	print("\n🆔 Próximo ID disponível: %s" % generate_next_id())
