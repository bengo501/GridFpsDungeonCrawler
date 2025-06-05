extends Control

func _ready():
	# Conectar sinais dos botões
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/SaveButton.pressed.connect(_on_save_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	
	# Esconder o menu inicialmente
	hide()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_resume_pressed()
		else:
			show()
			get_viewport().set_input_as_handled()

func _on_resume_pressed():
	hide()
	GameStateManager.resume()

func _on_save_pressed():
	GameStateManager.change_state(GameStateManager.GameState.SAVE_MENU)

func _on_options_pressed():
	GameStateManager.change_state(GameStateManager.GameState.OPTIONS_MENU)

func _on_main_menu_pressed():
	GameStateManager.change_state(GameStateManager.GameState.MAIN_MENU) 