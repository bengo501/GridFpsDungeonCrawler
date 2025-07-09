extends Node3D

func _ready():
	# Configurar o mundo de teste
	setup_test_world()

func setup_test_world():
	# Adicionar alguns itens iniciais ao jogador
	GameManager.add_item_to_inventory("health_potion")
	GameManager.add_item_to_inventory("mana_potion")
	GameManager.add_gold(100)
	
	# Emitir sinais para atualizar a UI
	GameManager.health_changed.emit(GameManager.player_health, GameManager.player_max_health)
	GameManager.mp_changed.emit(GameManager.player_mp, GameManager.player_max_mp)
	GameManager.gold_changed.emit(GameManager.player_gold)
	
	print("Mundo de teste configurado!")
	print("Itens iniciais adicionados ao inventário")
	print("Use WASD para se mover, F para interagir, ESC para pausar")

func spawn_enemy(enemy_type: String, position: Vector3):
	# Função para spawnar inimigos dinamicamente
	var enemy_scene = preload("res://scenes/Enemy.tscn")  # Assumindo que existe
	var enemy = enemy_scene.instantiate()
	enemy.enemy_id = enemy_type
	enemy.global_position = position
	add_child(enemy)

func spawn_chest(position: Vector3, contents: Array[String] = ["health_potion"], gold: int = 50):
	# Função para spawnar baús dinamicamente
	var chest_scene = preload("res://scenes/Chest.tscn")  # Assumindo que existe
	var chest = chest_scene.instantiate()
	chest.chest_contents = contents
	chest.gold_amount = gold
	chest.global_position = position
	add_child(chest)

func spawn_npc(position: Vector3, npc_name: String, dialog: Array[String]):
	# Função para spawnar NPCs dinamicamente
	var npc_scene = preload("res://scenes/NPC.tscn")  # Assumindo que existe
	var npc = npc_scene.instantiate()
	npc.npc_name = npc_name
	npc.greeting_dialog = dialog
	npc.global_position = position
	add_child(npc)

func _input(event):
	# Cheats para teste
	if event.is_action_pressed("ui_accept") and Input.is_key_pressed(KEY_CTRL):
		# Ctrl+Enter para spawnar inimigo de teste
		var player = get_tree().get_first_node_in_group("player")
		if player:
			spawn_enemy("goblin", player.global_position + Vector3(4, 0, 0))
			print("Inimigo spawned!")
	
	elif event.is_action_pressed("ui_cancel") and Input.is_key_pressed(KEY_CTRL):
		# Ctrl+ESC para spawnar baú de teste
		var player = get_tree().get_first_node_in_group("player")
		if player:
			spawn_chest(player.global_position + Vector3(0, 0, 4))
			print("Baú spawned!")
	
	elif Input.is_key_pressed(KEY_1) and Input.is_key_pressed(KEY_CTRL):
		# Ctrl+1 para ganhar experiência
		GameManager.gain_experience(50)
		print("Experiência adicionada!")
	
	elif Input.is_key_pressed(KEY_2) and Input.is_key_pressed(KEY_CTRL):
		# Ctrl+2 para curar completamente
		GameManager.update_player_health(GameManager.player_max_health)
		GameManager.update_player_mp(GameManager.player_max_mp)
		print("Vida e MP restaurados!")
	
	elif Input.is_key_pressed(KEY_3) and Input.is_key_pressed(KEY_CTRL):
		# Ctrl+3 para iniciar batalha de teste
		BattleManager.start_battle("goblin")
		GameStateManager.change_state(GameStateManager.GameState.IN_BATTLE)
		print("Batalha iniciada!")

func _on_player_entered_battle_zone():
	# Exemplo de trigger para batalha
	var enemies = ["goblin", "orc", "skeleton"]
	var random_enemy = enemies[randi() % enemies.size()]
	BattleManager.start_battle(random_enemy)
	GameStateManager.change_state(GameStateManager.GameState.IN_BATTLE) 