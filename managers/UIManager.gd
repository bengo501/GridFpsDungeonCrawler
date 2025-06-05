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

# Instâncias atuais
var transition_ui = null
var is_transitioning = false

func _ready():
    ui_container = get_node("/root/World/UIContainer")
    
    # Conectar sinais do GameStateManager
    GameStateManager.state_changed.connect(_on_game_state_changed)
    
    # Criar instâncias iniciais
    for ui_name in ui_scenes:
        var instance = ui_scenes[ui_name].instantiate()
        ui_container.add_child(instance)
        current_ui = instance
        instance.hide()

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
    if is_transitioning:
        return
    
    # Esconder todas as UIs
    for ui in ui_scenes.values():
        ui.hide()
    
    # Mostrar a UI solicitada
    if screen in ui_scenes:
        current_ui = ui_scenes[screen].instantiate()
        ui_container.add_child(current_ui)
        current_ui.show()
        menu_changed.emit(screen)

func show_dialog(dialog_id: String):
    show_ui(UIScreen.DIALOG_HUD)
    dialog_started.emit(dialog_id)

func show_interaction(interaction_id: String):
    show_ui(UIScreen.INTERACTION_HUD)
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