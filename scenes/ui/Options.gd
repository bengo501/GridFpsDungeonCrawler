extends Control

func _ready():
	# Conectar sinais
	$VBoxContainer/VolumeSlider.value_changed.connect(_on_volume_changed)
	$VBoxContainer/DifficultyOption.item_selected.connect(_on_difficulty_changed)
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# Carregar configurações atuais
	$VBoxContainer/VolumeSlider.value = GameManager.volume
	$VBoxContainer/DifficultyOption.selected = GameManager.difficulty

func _on_volume_changed(value):
	GameManager.volume = value
	# Atualizar volume do áudio
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_difficulty_changed(index):
	GameManager.difficulty = index

func _on_back_pressed():
	# Voltar para o estado anterior
	GameStateManager.change_state(GameStateManager.previous_state) 