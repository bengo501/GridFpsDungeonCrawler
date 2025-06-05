extends Control

func _ready():
	# Conectar sinais dos botões
	$VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	
	# Esconder o menu inicialmente
	hide()

func show_game_over():
	# Atualizar estatísticas
	$VBoxContainer/LevelLabel.text = "Nível alcançado: %d" % GameManager.player_level
	$VBoxContainer/TimeLabel.text = "Tempo de jogo: %s" % _format_time(GameManager.play_time)
	$VBoxContainer/EnemiesLabel.text = "Inimigos derrotados: %d" % GameManager.defeated_enemies.size()
	
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