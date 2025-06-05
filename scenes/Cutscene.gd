extends Node3D

# Referências
@onready var cutscene_area = $CutsceneArea
@onready var dialog_hud = $UIContainer/DialogHUD

# Variáveis
var cutscene_data = {}
var current_dialog_index = 0
var cutscene_completed = false

func _ready():
	# Conectar sinais
	GameStateManager.game_state_changed.connect(_on_game_state_changed)
	dialog_hud.dialog_ended.connect(_on_dialog_ended)
	
	# Carregar dados da cutscene
	load_cutscene_data()

func load_cutscene_data():
	# Carregar dados da cutscene atual
	cutscene_data = GameManager.current_cutscene_data
	
	# Configurar área da cutscene
	setup_cutscene_area()
	
	# Iniciar diálogo
	start_dialog()

func setup_cutscene_area():
	# Configurar elementos da cutscene baseado nos dados
	pass

func start_dialog():
	if cutscene_data.has("dialogs") and cutscene_data["dialogs"].size() > 0:
		var dialog = cutscene_data["dialogs"][current_dialog_index]
		dialog_hud.show_dialog(dialog)

func _on_dialog_ended():
	current_dialog_index += 1
	
	if current_dialog_index < cutscene_data["dialogs"].size():
		# Próximo diálogo
		start_dialog()
	else:
		# Cutscene terminada
		cutscene_completed = true
		GameManager.complete_cutscene()
		GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)

func _on_game_state_changed(new_state: int):
	match new_state:
		GameStateManager.GameState.CUTSCENE:
			# Mostrar HUD de diálogo
			dialog_hud.show()
		GameStateManager.GameState.PAUSED:
			# Pausar cutscene
			dialog_hud.hide()
		GameStateManager.GameState.EXPLORATION:
			# Voltar para exploração
			SceneManager.change_scene("world") 