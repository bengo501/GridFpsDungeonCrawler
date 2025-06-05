extends Node

# Referências
@onready var dialog_hud = $UIContainer/DialogHUD

# Variáveis
var dialog_data = {}
var current_dialog_index = 0
var dialog_completed = false

func _ready():
	# Conectar sinais
	GameStateManager.game_state_changed.connect(_on_game_state_changed)
	dialog_hud.dialog_ended.connect(_on_dialog_ended)
	
	# Carregar dados do diálogo
	load_dialog_data()

func load_dialog_data():
	# Carregar dados do diálogo atual
	dialog_data = GameManager.current_dialog_data
	
	# Iniciar diálogo
	start_dialog()

func start_dialog():
	if dialog_data.has("dialogs") and dialog_data["dialogs"].size() > 0:
		var dialog = dialog_data["dialogs"][current_dialog_index]
		dialog_hud.show_dialog(dialog)

func _on_dialog_ended():
	current_dialog_index += 1
	
	if current_dialog_index < dialog_data["dialogs"].size():
		# Próximo diálogo
		start_dialog()
	else:
		# Diálogo terminado
		dialog_completed = true
		
		# Processar resultado do diálogo
		process_dialog_result()
		
		# Voltar para estado anterior
		GameStateManager.change_state(GameStateManager.previous_state)

func process_dialog_result():
	# Processar resultado do diálogo
	var result = dialog_data.get("result", {})
	
	# Aplicar resultado
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
	
	if result.has("battle"):
		GameManager.start_battle(result["battle"])
	
	if result.has("puzzle"):
		GameManager.start_puzzle(result["puzzle"])

func _on_game_state_changed(new_state: int):
	match new_state:
		GameStateManager.GameState.DIALOG:
			# Mostrar HUD de diálogo
			dialog_hud.show()
		GameStateManager.GameState.PAUSED:
			# Pausar diálogo
			dialog_hud.hide()
		GameStateManager.GameState.EXPLORATION:
			# Voltar para exploração
			dialog_hud.hide() 