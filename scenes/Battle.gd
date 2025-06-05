extends Node3D

# Referências
@onready var player = $Player
@onready var enemy = $Enemy
@onready var battle_hud = $UIContainer/BattleHUD

func _ready():
	# Conectar sinais
	BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)
	BattleManager.turn_changed.connect(_on_turn_changed)
	BattleManager.damage_dealt.connect(_on_damage_dealt)
	BattleManager.enemy_defeated.connect(_on_enemy_defeated)
	BattleManager.player_defeated.connect(_on_player_defeated)
	
	# Iniciar batalha
	BattleManager.start_battle()

func _on_battle_started():
	# Posicionar jogador e inimigo
	player.position = Vector3(-2, 0, 0)
	enemy.position = Vector3(2, 0, 0)
	
	# Carregar dados do inimigo
	BattleManager.load_enemy_data()
	
	# Carregar dados do jogador
	BattleManager.load_player_battle_data()

func _on_battle_ended(victory: bool):
	if victory:
		# Recompensas da batalha
		var exp_gained = BattleManager.enemy_experience
		var gold_gained = BattleManager.enemy_gold
		
		GameManager.add_experience(exp_gained)
		GameManager.add_gold(gold_gained)
		
		# Voltar para exploração
		SceneManager.change_scene("world")
	else:
		# Game over
		GameStateManager.change_state(GameStateManager.GameState.GAME_OVER)

func _on_turn_changed(turn: int):
	# Atualizar animações baseado no turno
	if turn == BattleManager.PLAYER_TURN:
		# Animar jogador
		pass
	else:
		# Animar inimigo
		pass

func _on_damage_dealt(attacker: String, target: String, damage: int):
	# Animar dano
	if target == "player":
		# Animar jogador tomando dano
		pass
	else:
		# Animar inimigo tomando dano
		pass

func _on_enemy_defeated():
	# Animar inimigo derrotado
	pass

func _on_player_defeated():
	# Animar jogador derrotado
	pass 