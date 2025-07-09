extends Node
class_name GameInitializer

# Script para inicializar o jogo com configurações padrão

static func initialize_game():
	print("Inicializando Grid FPS Dungeon Crawler...")
	
	# Configurar input map se necessário
	setup_input_actions()
	
	# Configurar layers de colisão
	setup_collision_layers()
	
	# Configurar configurações padrão
	setup_default_settings()
	
	print("Jogo inicializado com sucesso!")

static func setup_input_actions():
	# Verificar se as ações já existem
	var required_actions = [
		"move_forward", "move_backward", "move_left", "move_right",
		"turn_left", "turn_right", "interact", "pause"
	]
	
	for action in required_actions:
		if not InputMap.has_action(action):
			print("Ação de input ausente: " + action)

static func setup_collision_layers():
	# Configurar nomes das layers de colisão
	var layer_names = {
		1: "Player",
		2: "Interactable", 
		4: "Walls",
		8: "Enemies"
	}
	
	for layer in layer_names:
		var layer_name = layer_names[layer]
		# Configurar no projeto se necessário
		print("Layer %d: %s" % [layer, layer_name])

static func setup_default_settings():
	# Configurar configurações padrão do jogo
	GameManager.difficulty = 1
	GameManager.volume = 1.0
	
	# Configurar itens iniciais
	GameManager.add_item_to_inventory("health_potion")
	GameManager.add_item_to_inventory("health_potion")
	GameManager.add_item_to_inventory("mana_potion")
	
	# Configurar áudio
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(GameManager.volume))

static func create_default_save():
	# Criar um save padrão para teste
	SaveManager.create_save("Jogo Inicial")
	print("Save padrão criado!")

static func validate_managers():
	# Validar se todos os managers estão carregados
	var managers = [
		"UIManager", "GameManager", "BattleManager", 
		"SaveManager", "GameStateManager", "SceneManager"
	]
	
	var all_valid = true
	for manager_name in managers:
		# Check if autoload exists by trying to access it
		var manager_exists = false
		match manager_name:
			"UIManager":
				manager_exists = UIManager != null
			"GameManager":
				manager_exists = GameManager != null
			"BattleManager":
				manager_exists = BattleManager != null
			"SaveManager":
				manager_exists = SaveManager != null
			"GameStateManager":
				manager_exists = GameStateManager != null
			"SceneManager":
				manager_exists = SceneManager != null
		
		if not manager_exists:
			print("ERRO: Manager não encontrado: " + manager_name)
			all_valid = false
		else:
			print("Manager carregado: " + manager_name)
	
	return all_valid

static func print_game_info():
	print("=== GRID FPS DUNGEON CRAWLER ===")
	print("Engine: Godot 4.4")
	print("Rendering: Forward Plus")
	print("Resolução: 1280x720")
	print("")
	print("Controles:")
	print("- WASD/Setas: Movimento")
	print("- Q/E: Rotação")
	print("- F: Interagir")
	print("- ESC: Pausar")
	print("")
	print("Cheats de Teste (Ctrl+):")
	print("- Ctrl+Enter: Spawnar inimigo")
	print("- Ctrl+ESC: Spawnar baú")
	print("- Ctrl+1: Ganhar experiência")
	print("- Ctrl+2: Curar completamente")
	print("- Ctrl+3: Iniciar batalha")
	print("===============================")

# Função para ser chamada no _ready() do MainMenu ou cena principal
static func full_initialization():
	print_game_info()
	
	if validate_managers():
		initialize_game()
		return true
	else:
		print("ERRO: Falha na validação dos managers!")
		return false 
