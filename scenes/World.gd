extends Node3D

# Referências
@onready var grid = $Grid
@onready var player = $Player
@onready var exploration_hud = $UIContainer/ExplorationHUD
@onready var battle_hud = $UIContainer/BattleHUD

func _ready():
	# Conectar sinais
	GameStateManager.state_changed.connect(_on_game_state_changed)
	BattleManager.battle_started.connect(_on_battle_started)
	BattleManager.battle_ended.connect(_on_battle_ended)
	
	# Inicializar o grid
	grid.initialize()
	
	# Posicionar o jogador
	player.position = grid.get_start_position()

func _on_game_state_changed(new_state: int):
	match new_state:
		GameStateManager.GameState.EXPLORATION:
			exploration_hud.show()
			battle_hud.hide()
			player.set_process_input(true)
		GameStateManager.GameState.IN_BATTLE:
			exploration_hud.hide()
			battle_hud.show()
			player.set_process_input(false)
		GameStateManager.GameState.PAUSED:
			player.set_process_input(false)
		GameStateManager.GameState.GAME_OVER:
			player.set_process_input(false)

func _on_battle_started():
	# Posicionar câmera para a batalha
	player.camera.position = Vector3(0, 2, -5)
	player.camera.look_at(Vector3(0, 2, 0))

func _on_battle_ended(victory: bool):
	# Restaurar posição da câmera
	player.camera.position = Vector3(0, 2, 0)
	player.camera.rotation = Vector3(0, 0, 0)
	
	if victory:
		# Recompensas da batalha
		var exp_gained = BattleManager.enemy_experience
		var gold_gained = BattleManager.enemy_gold
		
		GameManager.add_experience(exp_gained)
		GameManager.add_gold(gold_gained)
		
		# Voltar para exploração
		GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)
	else:
		# Game over
		GameStateManager.change_state(GameStateManager.GameState.GAME_OVER) 