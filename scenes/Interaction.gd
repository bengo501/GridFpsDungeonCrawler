extends Node

# Referências
@onready var interaction_hud = $UIContainer/InteractionHUD

# Variáveis
var interaction_data = {}

func _ready():
	# Conectar sinais
	GameStateManager.game_state_changed.connect(_on_game_state_changed)
	interaction_hud.interaction_ended.connect(_on_interaction_ended)
	
	# Carregar dados da interação
	load_interaction_data()

func load_interaction_data():
	# Carregar dados da interação atual
	interaction_data = GameManager.current_interaction_data
	
	# Configurar HUD
	setup_interaction_hud()

func setup_interaction_hud():
	# Configurar HUD baseado nos dados
	var title = interaction_data.get("title", "")
	var description = interaction_data.get("description", "")
	var options = interaction_data.get("options", [])
	
	interaction_hud.set_interaction(title, description, options)

func _on_interaction_ended(option_selected: int):
	# Processar opção selecionada
	var result = process_option(option_selected)
	
	# Aplicar resultado
	apply_interaction_result(result)
	
	# Voltar para exploração
	GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)

func process_option(option_index: int) -> Dictionary:
	# Processar opção selecionada
	var options = interaction_data.get("options", [])
	if option_index >= 0 and option_index < options.size():
		return options[option_index].get("result", {})
	return {}

func apply_interaction_result(result: Dictionary):
	# Aplicar resultado da interação
	if result.has("experience"):
		GameManager.add_experience(result["experience"])
	
	if result.has("gold"):
		GameManager.add_gold(result["gold"])
	
	if result.has("item"):
		GameManager.add_item(result["item"])
	
	if result.has("quest"):
		GameManager.update_quest(result["quest"])
	
	if result.has("cutscene"):
		GameManager.start_cutscene(result["cutscene"])

func _on_game_state_changed(new_state: int):
	match new_state:
		GameStateManager.GameState.INTERACTION:
			# Mostrar HUD de interação
			interaction_hud.show()
		GameStateManager.GameState.PAUSED:
			# Pausar interação
			interaction_hud.hide()
		GameStateManager.GameState.EXPLORATION:
			# Voltar para exploração
			interaction_hud.hide() 