extends Control

func _ready():
	# Aguarda um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Conectar sinais com verificações de segurança
	var attack_button = get_node_or_null("BattleMenu/AttackButton")
	var skill_button = get_node_or_null("BattleMenu/SkillButton")
	var item_button = get_node_or_null("BattleMenu/ItemButton")
	var flee_button = get_node_or_null("BattleMenu/FleeButton")
	
	if attack_button:
		attack_button.pressed.connect(_on_attack_pressed)
	
	if skill_button:
		skill_button.pressed.connect(_on_skill_pressed)
	
	if item_button:
		item_button.pressed.connect(_on_item_pressed)
	
	if flee_button:
		flee_button.pressed.connect(_on_flee_pressed)
	
	# Conectar sinais do BattleManager
	BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)
	BattleManager.turn_changed.connect(_on_turn_changed)
	BattleManager.damage_dealt.connect(_on_damage_dealt)
	BattleManager.enemy_defeated.connect(_on_enemy_defeated)
	BattleManager.player_defeated.connect(_on_player_defeated)
	
	# Esconder menu de batalha inicialmente
	hide_battle_menu()

func update_player_health(health: float, max_health: float):
	var health_bar = get_node_or_null("PlayerStats/HealthBar")
	var health_label = get_node_or_null("PlayerStats/HealthBar/HealthLabel")
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	if health_label:
		health_label.text = "Vida: %d/%d" % [health, max_health]

func update_enemy_health(health: float, max_health: float):
	var health_bar = get_node_or_null("EnemyStats/HealthBar")
	var health_label = get_node_or_null("EnemyStats/HealthBar/HealthLabel")
	var enemy_name = get_node_or_null("EnemyStats/EnemyName")
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	if health_label:
		health_label.text = "Vida: %d/%d" % [health, max_health]
	
	if enemy_name and BattleManager:
		enemy_name.text = BattleManager.enemy_name

func add_battle_log(text: String):
	var battle_log = get_node_or_null("BattleLog")
	if battle_log:
		battle_log.append_text(text + "\n")

func show_battle_menu():
	var battle_menu = get_node_or_null("BattleMenu")
	if battle_menu:
		battle_menu.show()

func hide_battle_menu():
	var battle_menu = get_node_or_null("BattleMenu")
	if battle_menu:
		battle_menu.hide()

func update_turn_display(turn: int):
	var battle_menu = get_node_or_null("BattleMenu")
	if battle_menu and BattleManager:
		battle_menu.visible = turn == BattleManager.PLAYER_TURN

func _on_battle_started():
	update_player_health(BattleManager.player_health, BattleManager.player_max_health)
	update_enemy_health(BattleManager.enemy_health, BattleManager.enemy_max_health)
	show_battle_menu()
	add_battle_log("Batalha iniciada!")

func _on_battle_ended(victory: bool):
	hide_battle_menu()
	if victory:
		add_battle_log("Você venceu!")
	else:
		add_battle_log("Você foi derrotado!")

func _on_turn_changed(turn: int):
	update_turn_display(turn)
	add_battle_log("Turno %d" % turn)

func _on_damage_dealt(attacker: String, target: String, damage: int):
	update_player_health(BattleManager.player_health, BattleManager.player_max_health)
	update_enemy_health(BattleManager.enemy_health, BattleManager.enemy_max_health)
	add_battle_log("%s causou %d de dano em %s" % [attacker, damage, target])

func _on_enemy_defeated():
	add_battle_log("Inimigo derrotado!")

func _on_player_defeated():
	add_battle_log("Você foi derrotado!")

func _on_attack_pressed():
	BattleManager.player_attack()

func _on_skill_pressed():
	_show_skill_menu()

func _on_item_pressed():
	_show_item_menu()

func _on_flee_pressed():
	var flee_success = BattleManager.attempt_flee()
	if flee_success:
		add_battle_log("Você fugiu da batalha!")
		BattleManager.end_battle(false)
	else:
		add_battle_log("Não foi possível fugir!")
		BattleManager.end_player_turn()

func _show_skill_menu():
	var battle_menu = get_node_or_null("BattleMenu")
	if not battle_menu:
		return
		
	# Esconder menu principal
	battle_menu.hide()
	
	# Criar menu de habilidades
	var skill_menu = VBoxContainer.new()
	skill_menu.name = "SkillMenu"
	add_child(skill_menu)
	
	var title = Label.new()
	title.text = "Escolha uma Habilidade:"
	skill_menu.add_child(title)
	
	# Adicionar habilidades do jogador
	var player_skills = GameManager.get_player_skills()
	for skill in player_skills:
		var button = Button.new()
		button.text = "%s (MP: %d)" % [skill.name, skill.mp_cost]
		button.disabled = GameManager.player_mp < skill.mp_cost
		button.pressed.connect(_on_skill_selected.bind(skill))
		skill_menu.add_child(button)
	
	# Botão voltar
	var back_button = Button.new()
	back_button.text = "Voltar"
	back_button.pressed.connect(_hide_skill_menu)
	skill_menu.add_child(back_button)

func _show_item_menu():
	var battle_menu = get_node_or_null("BattleMenu")
	if not battle_menu:
		return
		
	# Esconder menu principal
	battle_menu.hide()
	
	# Criar menu de itens
	var item_menu = VBoxContainer.new()
	item_menu.name = "ItemMenu"
	add_child(item_menu)
	
	var title = Label.new()
	title.text = "Escolha um Item:"
	item_menu.add_child(title)
	
	# Adicionar itens do jogador
	var player_items = GameManager.get_player_items()
	for item in player_items:
		if item.quantity > 0 and item.usable_in_battle:
			var button = Button.new()
			button.text = "%s (x%d)" % [item.name, item.quantity]
			button.pressed.connect(_on_item_selected.bind(item))
			item_menu.add_child(button)
	
	# Botão voltar
	var back_button = Button.new()
	back_button.text = "Voltar"
	back_button.pressed.connect(_hide_item_menu)
	item_menu.add_child(back_button)

func _on_skill_selected(skill: Dictionary):
	BattleManager.player_use_skill(skill)
	_hide_skill_menu()

func _on_item_selected(item: Dictionary):
	BattleManager.player_use_item(item)
	_hide_item_menu()

func _hide_skill_menu():
	var skill_menu = get_node_or_null("SkillMenu")
	if skill_menu:
		skill_menu.queue_free()
	show_battle_menu()

func _hide_item_menu():
	var item_menu = get_node_or_null("ItemMenu")
	if item_menu:
		item_menu.queue_free()
	show_battle_menu() 