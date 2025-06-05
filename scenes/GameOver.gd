extends Node

# Referências
@onready var game_over_ui = $UIContainer/GameOver

func _ready():
	# Conectar sinais
	game_over_ui.retry_pressed.connect(_on_retry_pressed)
	game_over_ui.main_menu_pressed.connect(_on_main_menu_pressed)
	game_over_ui.quit_pressed.connect(_on_quit_pressed)
	
	# Mostrar estatísticas
	show_game_stats()

func show_game_stats():
	# Mostrar estatísticas do jogo
	var play_time = GameManager.play_time
	var enemies_defeated = GameManager.enemies_defeated
	var puzzles_solved = GameManager.puzzles_solved
	var gold_collected = GameManager.gold_collected
	
	game_over_ui.set_stats(play_time, enemies_defeated, puzzles_solved, gold_collected)

func _on_retry_pressed():
	# Carregar último save
	if SaveManager.has_saves():
		SaveManager.load_save(SaveManager.current_save_id)
		GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)
	else:
		# Novo jogo
		GameManager.start_new_game()
		GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)

func _on_main_menu_pressed():
	# Voltar para menu principal
	GameStateManager.change_state(GameStateManager.GameState.MAIN_MENU)

func _on_quit_pressed():
	# Sair do jogo
	get_tree().quit() 