extends Control

func _ready():
	# Aguarda um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Conectar sinais com verificações de segurança
	var volume_slider = get_node_or_null("VBoxContainer/VolumeSlider")
	var difficulty_option = get_node_or_null("VBoxContainer/DifficultyOption")
	var back_button = get_node_or_null("VBoxContainer/BackButton")
	
	if volume_slider:
		volume_slider.value_changed.connect(_on_volume_changed)
	
	if difficulty_option:
		difficulty_option.item_selected.connect(_on_difficulty_changed)
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	# Carregar configurações atuais
	load_settings()

func load_settings():
	var volume_slider = get_node_or_null("VBoxContainer/VolumeSlider")
	var difficulty_option = get_node_or_null("VBoxContainer/DifficultyOption")
	
	if volume_slider and GameManager:
		volume_slider.value = GameManager.volume
	
	if difficulty_option and GameManager:
		difficulty_option.selected = GameManager.difficulty

func _on_volume_changed(value):
	GameManager.volume = value
	# Atualizar volume do áudio
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_difficulty_changed(index):
	GameManager.difficulty = index

func _on_back_pressed():
	# Voltar para o estado anterior
	GameStateManager.change_state(GameStateManager.previous_state) 