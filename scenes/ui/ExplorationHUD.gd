extends Control

func _ready():
	# Conectar sinais do GameManager
	GameManager.player_health_changed.connect(_on_player_health_changed)
	GameManager.player_level_changed.connect(_on_player_level_changed)
	GameManager.player_experience_changed.connect(_on_player_experience_changed)
	GameManager.player_gold_changed.connect(_on_player_gold_changed)
	
	# Esconder label de interação inicialmente
	$InteractionLabel.hide()
	
	# Atualizar valores iniciais
	_update_health_display()
	_update_level_display()
	_update_experience_display()
	_update_gold_display()

func _update_health_display():
	var health = GameManager.player_health
	var max_health = GameManager.player_max_health
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	$HealthBar/HealthLabel.text = "Vida: %d/%d" % [health, max_health]

func _update_level_display():
	$LevelLabel.text = "Nível: %d" % GameManager.player_level

func _update_experience_display():
	var exp = GameManager.player_experience
	var exp_to_next = GameManager.player_experience_to_next_level
	$ExperienceBar.max_value = exp_to_next
	$ExperienceBar.value = exp
	$ExperienceBar/ExperienceLabel.text = "EXP: %d/%d" % [exp, exp_to_next]

func _update_gold_display():
	$GoldLabel.text = "Ouro: %d" % GameManager.player_gold

func _on_player_health_changed():
	_update_health_display()

func _on_player_level_changed():
	_update_level_display()
	_update_experience_display()

func _on_player_experience_changed():
	_update_experience_display()

func _on_player_gold_changed():
	_update_gold_display()

func show_interaction_prompt(show: bool):
	$InteractionLabel.visible = show 