extends Control

func _ready():
	# Conectar sinais do GameManager
	GameManager.health_changed.connect(update_health)
	GameManager.mp_changed.connect(update_mp)
	GameManager.experience_changed.connect(update_experience)
	GameManager.gold_changed.connect(update_gold)
	GameManager.level_changed.connect(update_level)
	
	# Esconder label de interação inicialmente
	var interaction_label = get_node_or_null("InteractionLabel")
	if interaction_label:
		interaction_label.hide()
	
	# Inicializar valores
	update_health(GameManager.player_health, GameManager.player_max_health)
	update_mp(GameManager.player_mp, GameManager.player_max_mp)
	update_experience(GameManager.player_experience, GameManager.get_experience_to_next_level())
	update_gold(GameManager.player_gold)
	update_level(GameManager.player_level)

func update_health(health: float, max_health: float):
	var health_bar = get_node_or_null("HealthBar")
	var health_label = get_node_or_null("HealthBar/HealthLabel")
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	if health_label:
		health_label.text = "Vida: %d/%d" % [health, max_health]

func update_mp(mp: float, max_mp: float):
	var mp_bar = get_node_or_null("MPBar")
	var mp_label = get_node_or_null("MPBar/MPLabel")
	
	if mp_bar:
		mp_bar.max_value = max_mp
		mp_bar.value = mp
	
	if mp_label:
		mp_label.text = "MP: %d/%d" % [mp, max_mp]

func update_level(level: int):
	var level_label = get_node_or_null("LevelLabel")
	if level_label:
		level_label.text = "Nível: %d" % level

func update_experience(exp: float, exp_to_next: float):
	var experience_bar = get_node_or_null("ExperienceBar")
	var experience_label = get_node_or_null("ExperienceBar/ExperienceLabel")
	
	if experience_bar:
		experience_bar.max_value = exp_to_next
		experience_bar.value = exp
	
	if experience_label:
		experience_label.text = "EXP: %d/%d" % [exp, exp_to_next]

func update_gold(gold: int):
	var gold_label = get_node_or_null("GoldLabel")
	if gold_label:
		gold_label.text = "Ouro: %d" % gold

func show_interaction_prompt(show: bool):
	var interaction_label = get_node_or_null("InteractionLabel")
	if interaction_label:
		interaction_label.visible = show 
