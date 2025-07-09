extends Node

func _ready():
	# Inicializar o jogo
	GameInitializer.full_initialization()
	
	# Aguarda um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Conectar sinais do menu com verificações de segurança
	var new_game_button = get_node_or_null("UIContainer/MainMenu/VBoxContainer/NewGameButton")
	var load_game_button = get_node_or_null("UIContainer/MainMenu/VBoxContainer/LoadGameButton")
	var options_button = get_node_or_null("UIContainer/MainMenu/VBoxContainer/OptionsButton")
	var quit_button = get_node_or_null("UIContainer/MainMenu/VBoxContainer/QuitButton")
	
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_pressed)
	else:
		print("Erro: NewGameButton não encontrado")
		
	if load_game_button:
		load_game_button.pressed.connect(_on_load_game_pressed)
	else:
		print("Erro: LoadGameButton não encontrado")
		
	if options_button:
		options_button.pressed.connect(_on_options_pressed)
	else:
		print("Erro: OptionsButton não encontrado")
		
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	else:
		print("Erro: QuitButton não encontrado")

func _on_new_game_pressed():
	# Resetar o jogo e iniciar novo
	GameManager.reset()
	
	# Configurar estado inicial
	GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)
	
	# Mudar para a cena do mundo
	SceneManager.change_scene("world")

func _on_load_game_pressed():
	# Abrir menu de carregamento
	GameStateManager.change_state(GameStateManager.GameState.SAVE_MENU)

func _on_options_pressed():
	# Abrir menu de opções
	GameStateManager.change_state(GameStateManager.GameState.OPTIONS_MENU)

func _on_quit_pressed():
	# Sair do jogo
	get_tree().quit() 
