extends Control

func _ready():
	# Conectar sinais dos botões
	$VBoxContainer/NewGameButton.pressed.connect(_on_new_game_pressed)
	$VBoxContainer/LoadGameButton.pressed.connect(_on_load_game_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	# Iniciar novo jogo
	GameManager.reset()
	GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)

func _on_load_game_pressed():
	# Abrir menu de carregamento
	GameStateManager.change_state(GameStateManager.GameState.SAVE_MENU)

func _on_options_pressed():
	# Abrir menu de opções
	GameStateManager.change_state(GameStateManager.GameState.OPTIONS_MENU)

func _on_quit_pressed():
	# Sair do jogo
	get_tree().quit() 