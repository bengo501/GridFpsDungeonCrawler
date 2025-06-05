extends Node

# Sinais para comunicação entre managers
signal scene_changed(scene_name: String)
signal scene_loaded
signal scene_load_progress(progress: float)
signal scene_load_error(error_message: String)

# Cenas do jogo
var scenes: Dictionary = {
    "main_menu": "res://scenes/MainMenu.tscn",
    "world": "res://scenes/World.tscn",
    "battle": "res://scenes/Battle.tscn",
    "puzzle": "res://scenes/Puzzle.tscn",
    "cutscene": "res://scenes/Cutscene.tscn"
}

var current_scene: Node
var loading_scene: Node
var loading_progress: float = 0.0

func _ready():
    # Conecta sinais com outros managers
    GameStateManager.state_changed.connect(_on_game_state_changed)

func change_scene(scene_name: String, show_loading: bool = true):
    if not scenes.has(scene_name):
        scene_load_error.emit("Cena não encontrada: " + scene_name)
        return
    
    if show_loading:
        show_loading_screen()
    
    # Inicia o carregamento da cena em background
    var loader = ResourceLoader.load_interactive(scenes[scene_name])
    
    if loader == null:
        scene_load_error.emit("Erro ao carregar cena: " + scene_name)
        return
    
    # Carrega a cena em partes
    while true:
        var error = loader.poll()
        
        if error == ERR_FILE_EOF:
            var resource = loader.get_resource()
            finish_scene_change(resource)
            break
        elif error == OK:
            loading_progress = float(loader.get_stage()) / loader.get_stage_count()
            scene_load_progress.emit(loading_progress)
        
        await get_tree().create_timer(0.1).timeout

func finish_scene_change(scene_resource: PackedScene):
    # Remove a cena atual
    if current_scene:
        current_scene.queue_free()
    
    # Instancia a nova cena
    current_scene = scene_resource.instantiate()
    get_tree().root.add_child(current_scene)
    
    # Remove a tela de loading
    if loading_scene:
        loading_scene.queue_free()
        loading_scene = null
    
    scene_changed.emit(current_scene.name)
    scene_loaded.emit()

func show_loading_screen():
    # Instancia a tela de loading
    var loading_scene_resource = load("res://scenes/LoadingScreen.tscn")
    loading_scene = loading_scene_resource.instantiate()
    get_tree().root.add_child(loading_scene)

func _on_game_state_changed(new_state: int):
    match new_state:
        GameStateManager.GameState.MAIN_MENU:
            change_scene("main_menu")
        GameStateManager.GameState.IN_BATTLE:
            change_scene("battle")
        GameStateManager.GameState.PUZZLE:
            change_scene("puzzle")
        GameStateManager.GameState.CUTSCENE:
            change_scene("cutscene")
        GameStateManager.GameState.EXPLORATION:
            change_scene("world") 