extends Node

# Sinais para comunicação entre managers
signal state_changed(new_state: int)
signal game_paused
signal game_resumed
signal game_over
signal battle_started
signal battle_ended
signal puzzle_started
signal puzzle_completed

# Estados do jogo
enum GameState {
    MAIN_MENU,
    PAUSED,
    PAUSE_MENU,
    GAME_OVER,
    IN_BATTLE,
    EXPLORATION,
    PUZZLE,
    DIALOG,
    INTERACTION,
    CUTSCENE,
    LOADING,
    SAVE_MENU,
    OPTIONS_MENU
}

var current_state: GameState = GameState.MAIN_MENU
var previous_state: GameState

func _ready():
    # Conecta sinais com outros managers
    UIManager.menu_changed.connect(_on_menu_changed)
    BattleManager.battle_ended.connect(_on_battle_ended)

func change_state(new_state: GameState):
    previous_state = current_state
    current_state = new_state
    state_changed.emit(new_state)
    
    match new_state:
        GameState.PAUSED:
            game_paused.emit()
        GameState.GAME_OVER:
            game_over.emit()
        GameState.IN_BATTLE:
            battle_started.emit()
        GameState.PUZZLE:
            puzzle_started.emit()

func pause_game():
    if current_state != GameState.PAUSED:
        change_state(GameState.PAUSED)

func resume_game():
    if current_state == GameState.PAUSED:
        change_state(previous_state)
        game_resumed.emit()

func start_battle():
    change_state(GameState.IN_BATTLE)

func start_puzzle():
    change_state(GameState.PUZZLE)

func start_dialog():
    change_state(GameState.DIALOG)

func start_interaction():
    change_state(GameState.INTERACTION)

func _on_menu_changed(menu_name: String):
    match menu_name:
        "MAIN_MENU":
            change_state(GameState.MAIN_MENU)
        "PAUSE":
            change_state(GameState.PAUSED)
        "GAME_OVER":
            change_state(GameState.GAME_OVER)
        "SAVE_SELECT":
            change_state(GameState.SAVE_MENU)
        "OPTIONS":
            change_state(GameState.OPTIONS_MENU)

func _on_battle_ended():
    change_state(GameState.EXPLORATION) 