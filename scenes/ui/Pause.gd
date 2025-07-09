extends Control

func _ready():
	# Aguarda um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Conectar sinais com verificações de segurança
	var resume_button = get_node_or_null("VBoxContainer/ResumeButton")
	var save_button = get_node_or_null("VBoxContainer/SaveButton")
	var options_button = get_node_or_null("VBoxContainer/OptionsButton")
	var main_menu_button = get_node_or_null("VBoxContainer/MainMenuButton")
	
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	
	if save_button:
		save_button.pressed.connect(_on_save_pressed)
	
	if options_button:
		options_button.pressed.connect(_on_options_pressed)
	
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	
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