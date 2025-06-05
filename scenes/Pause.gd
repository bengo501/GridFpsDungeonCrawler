extends Node

# Referências
@onready var pause_ui = $UIContainer/Pause

func _ready():
	# Conectar sinais
	pause_ui.resume_pressed.connect(_on_resume_pressed)
	pause_ui.options_pressed.connect(_on_options_pressed)
	pause_ui.save_pressed.connect(_on_save_pressed)
	pause_ui.main_menu_pressed.connect(_on_main_menu_pressed)
	pause_ui.quit_pressed.connect(_on_quit_pressed)
	
	# Pausar jogo
	get_tree().paused = true

func _exit_tree():
	# Despausar jogo
	get_tree().paused = false

func _on_resume_pressed():
	# Voltar para jogo
	GameStateManager.change_state(GameStateManager.previous_state)

func _on_options_pressed():
	# Abrir opções
	GameStateManager.change_state(GameStateManager.GameState.OPTIONS)

func _on_save_pressed():
	# Salvar jogo
	SaveManager.create_save()
	
	# Mostrar mensagem de sucesso
	pause_ui.show_save_success()

func _on_main_menu_pressed():
	# Voltar para menu principal
	GameStateManager.change_state(GameStateManager.GameState.MAIN_MENU)

func _on_quit_pressed():
	# Sair do jogo
	get_tree().quit() 