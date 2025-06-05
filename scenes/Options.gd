extends Node

# Referências
@onready var options_ui = $UIContainer/Options

func _ready():
	# Conectar sinais
	options_ui.back_pressed.connect(_on_back_pressed)
	options_ui.apply_pressed.connect(_on_apply_pressed)
	options_ui.reset_pressed.connect(_on_reset_pressed)
	
	# Carregar configurações
	load_settings()

func load_settings():
	# Carregar configurações atuais
	var settings = GameManager.game_settings
	
	# Aplicar configurações na UI
	options_ui.set_master_volume(settings.get("master_volume", 1.0))
	options_ui.set_music_volume(settings.get("music_volume", 1.0))
	options_ui.set_sfx_volume(settings.get("sfx_volume", 1.0))
	options_ui.set_fullscreen(settings.get("fullscreen", false))
	options_ui.set_vsync(settings.get("vsync", true))
	options_ui.set_difficulty(settings.get("difficulty", 1))

func _on_back_pressed():
	# Voltar para cena anterior
	GameStateManager.change_state(GameStateManager.previous_state)

func _on_apply_pressed():
	# Aplicar configurações
	var settings = {
		"master_volume": options_ui.get_master_volume(),
		"music_volume": options_ui.get_music_volume(),
		"sfx_volume": options_ui.get_sfx_volume(),
		"fullscreen": options_ui.get_fullscreen(),
		"vsync": options_ui.get_vsync(),
		"difficulty": options_ui.get_difficulty()
	}
	
	GameManager.apply_settings(settings)
	
	# Voltar para cena anterior
	GameStateManager.change_state(GameStateManager.previous_state)

func _on_reset_pressed():
	# Resetar configurações para padrão
	options_ui.reset_settings() 