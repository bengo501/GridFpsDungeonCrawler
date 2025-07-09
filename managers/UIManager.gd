extends Node

# Sinais para comunicação entre managers
signal menu_changed(menu_name: String)
signal dialog_started(dialog_id: String)
signal dialog_ended
signal interaction_started(interaction_id: String)
signal interaction_ended

# Sinais
signal ui_transition_started
signal ui_transition_finished

# Enums para os diferentes tipos de UI
enum UIScreen {
	MAIN_MENU,
	GAME_OVER,
	OPTIONS,
	PAUSE,
	SAVE_SELECT,
	EXPLORATION_HUD,
	INTERACTION_HUD,
	DIALOG_HUD,
	BATTLE_HUD
}

# Referências para as cenas de UI
var ui_scenes: Dictionary = {
	UIScreen.MAIN_MENU: preload("res://scenes/ui/MainMenu.tscn"),
	UIScreen.GAME_OVER: preload("res://scenes/ui/GameOver.tscn"),
	UIScreen.OPTIONS: preload("res://scenes/ui/Options.tscn"),
	UIScreen.PAUSE: preload("res://scenes/ui/Pause.tscn"),
	UIScreen.SAVE_SELECT: preload("res://scenes/ui/SaveSelect.tscn"),
	UIScreen.EXPLORATION_HUD: preload("res://scenes/ui/ExplorationHUD.tscn"),
	UIScreen.INTERACTION_HUD: preload("res://scenes/ui/InteractionHUD.tscn"),
	UIScreen.DIALOG_HUD: preload("res://scenes/ui/DialogHUD.tscn"),
	UIScreen.BATTLE_HUD: preload("res://scenes/ui/BattleHUD.tscn")
}

var current_ui: Node
var ui_container: Node
var ui_instances: Dictionary = {}

# Instâncias atuais
var transition_ui = null
var is_transitioning = false

func _ready():
	# Aguarda um frame para garantir que a árvore de cenas esteja pronta
	await get_tree().process_frame
	
	# Tenta encontrar o UIContainer, se não encontrar, cria um
	ui_container = get_node_or_null("/root/World/UIContainer")
	
	if ui_container == null:
		# Cria um UIContainer na raiz se não existir
		ui_container = CanvasLayer.new()
		ui_container.name = "UIContainer"
		get_tree().root.add_child(ui_container)
	
	# Conectar sinais do GameStateManager
	GameStateManager.state_changed.connect(_on_game_state_changed)
	
	# Criar instâncias iniciais apenas se o ui_container existir
	if ui_container:
		for ui_name in ui_scenes:
			var scene_resource = ui_scenes[ui_name]
			if scene_resource:
				var instance = scene_resource.instantiate()
				if instance:
					ui_container.add_child(instance)
					ui_instances[ui_name] = instance
					instance.hide()
				else:
					print("Erro: Não foi possível instanciar a UI: ", ui_name)
			else:
				print("Erro: Recurso de UI não encontrado: ", ui_name)

func _on_game_state_changed(new_state: int):
	match new_state:
		GameStateManager.GameState.MAIN_MENU:
			_show_ui(UIScreen.MAIN_MENU)
		GameStateManager.GameState.PAUSED:
			_show_ui(UIScreen.PAUSE)
		GameStateManager.GameState.OPTIONS_MENU:
			_show_ui(UIScreen.OPTIONS)
		GameStateManager.GameState.SAVE_MENU:
			_show_ui(UIScreen.SAVE_SELECT)
		GameStateManager.GameState.GAME_OVER:
			_show_ui(UIScreen.GAME_OVER)
			current_ui.show_game_over()
		GameStateManager.GameState.IN_BATTLE:
			_show_ui(UIScreen.BATTLE_HUD)
		GameStateManager.GameState.EXPLORATION:
			_show_ui(UIScreen.EXPLORATION_HUD)
		GameStateManager.GameState.DIALOG:
			_show_ui(UIScreen.DIALOG_HUD)
		GameStateManager.GameState.INTERACTION:
			_show_ui(UIScreen.INTERACTION_HUD)

func _show_ui(screen: UIScreen):
	if is_transitioning or ui_container == null:
		return
	
	# Esconder todas as UIs
	for ui_instance in ui_instances.values():
		if ui_instance and is_instance_valid(ui_instance):
			ui_instance.hide()
	
	# Mostrar a UI solicitada
	if screen in ui_instances:
		current_ui = ui_instances[screen]
		if current_ui and is_instance_valid(current_ui):
			current_ui.show()
			menu_changed.emit(screen)

func show_dialog(dialog_id: String):
	if ui_container == null:
		return
	_show_ui(UIScreen.DIALOG_HUD)
	dialog_started.emit(dialog_id)

func show_interaction(interaction_id: String):
	if ui_container == null:
		return
	_show_ui(UIScreen.INTERACTION_HUD)
	interaction_started.emit(interaction_id)

func update_player_hud(health: float, max_health: float, items: Array):
	if current_ui and current_ui.has_method("update_player_stats"):
		current_ui.update_player_stats(health, max_health, items)

func update_battle_hud(player_health: float, enemy_health: float, turn: int):
	if current_ui and current_ui.has_method("update_battle_stats"):
		current_ui.update_battle_stats(player_health, enemy_health, turn)

func start_transition(transition_type: String, duration: float = 1.0):
	if is_transitioning:
		return
	
	is_transitioning = true
	ui_transition_started.emit()
	
	# TODO: Implementar transições visuais
	
	await get_tree().create_timer(duration).timeout
	
	is_transitioning = false
	ui_transition_finished.emit() 
