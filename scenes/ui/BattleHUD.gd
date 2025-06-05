extends Control

func _ready():
	# Conectar sinais
	$BattleMenu/AttackButton.pressed.connect(_on_attack_pressed)
	$BattleMenu/SkillButton.pressed.connect(_on_skill_pressed)
	$BattleMenu/ItemButton.pressed.connect(_on_item_pressed)
	$BattleMenu/FleeButton.pressed.connect(_on_flee_pressed)
	
	# Conectar sinais do BattleManager
	BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)
	BattleManager.turn_changed.connect(_on_turn_changed)
	BattleManager.damage_dealt.connect(_on_damage_dealt)
	BattleManager.enemy_defeated.connect(_on_enemy_defeated)
	BattleManager.player_defeated.connect(_on_player_defeated)
	
	# Esconder menu de batalha inicialmente
	$BattleMenu.hide()

func _update_player_stats():
	var health = BattleManager.player_health
	var max_health = BattleManager.player_max_health
	$PlayerStats/HealthBar.max_value = max_health
	$PlayerStats/HealthBar.value = health
	$PlayerStats/HealthBar/HealthLabel.text = "Vida: %d/%d" % [health, max_health]

func _update_enemy_stats():
	var health = BattleManager.enemy_health
	var max_health = BattleManager.enemy_max_health
	$EnemyStats/HealthBar.max_value = max_health
	$EnemyStats/HealthBar.value = health
	$EnemyStats/HealthBar/HealthLabel.text = "Vida: %d/%d" % [health, max_health]
	$EnemyStats/EnemyName.text = BattleManager.enemy_name

func _add_battle_log(text: String):
	$BattleLog.append_text(text + "\n")

func _on_battle_started():
	_update_player_stats()
	_update_enemy_stats()
	$BattleMenu.show()
	_add_battle_log("Batalha iniciada!")

func _on_battle_ended(victory: bool):
	$BattleMenu.hide()
	if victory:
		_add_battle_log("Você venceu!")
	else:
		_add_battle_log("Você foi derrotado!")

func _on_turn_changed(turn: int):
	$BattleMenu.visible = turn == BattleManager.PLAYER_TURN
	_add_battle_log("Turno %d" % turn)

func _on_damage_dealt(attacker: String, target: String, damage: int):
	_update_player_stats()
	_update_enemy_stats()
	_add_battle_log("%s causou %d de dano em %s" % [attacker, damage, target])

func _on_enemy_defeated():
	_add_battle_log("Inimigo derrotado!")

func _on_player_defeated():
	_add_battle_log("Você foi derrotado!")

func _on_attack_pressed():
	BattleManager.player_attack()

func _on_skill_pressed():
	# TODO: Implementar seleção de habilidade
	pass

func _on_item_pressed():
	# TODO: Implementar seleção de item
	pass

func _on_flee_pressed():
	# TODO: Implementar tentativa de fuga
	pass 