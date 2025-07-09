extends Control

func _ready():
	# Aguarda um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Conectar sinais com verificações de segurança
	var retry_button = get_node_or_null("VBoxContainer/RetryButton")
	var main_menu_button = get_node_or_null("VBoxContainer/MainMenuButton")
	
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Esconder o menu inicialmente
	hide()

func show_game_over():
	var level_label = get_node_or_null("VBoxContainer/LevelLabel")
	var time_label = get_node_or_null("VBoxContainer/TimeLabel")
	var enemies_label = get_node_or_null("VBoxContainer/EnemiesLabel")
	
	if level_label and GameManager:
		level_label.text = "Nível alcançado: %d" % GameManager.player_level
	
	if time_label and GameManager:
		time_label.text = "Tempo de jogo: %s" % _format_time(GameManager.play_time)
	
	if enemies_label and GameManager:
		enemies_label.text = "Inimigos derrotados: %d" % GameManager.defeated_enemies.size()
	
	show()

func _format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	return "%d:%02d" % [minutes, remaining_seconds]

func _on_retry_pressed():
	# Reiniciar o jogo
	GameManager.reset()
	GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)

func _on_main_menu_pressed():
	# Voltar ao menu principal
	GameStateManager.change_state(GameStateManager.GameState.MAIN_MENU) 