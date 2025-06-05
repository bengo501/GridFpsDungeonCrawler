extends Node3D

# Referências
@onready var grid = $Grid
@onready var player = $Player
@onready var camera = $Player/Camera3D
@onready var exploration_hud = $UIContainer/ExplorationHUD

# Variáveis
var current_room = null
var current_cell = Vector2i.ZERO
var player_rotation = 0

func _ready():
	# Conectar sinais
	GameStateManager.game_state_changed.connect(_on_game_state_changed)
	
	# Inicializar grid
	initialize_grid()
	
	# Posicionar jogador
	position_player()

func initialize_grid():
	# Carregar dados do grid
	var grid_data = GameManager.current_grid_data
	
	# Configurar grid
	grid.setup_grid(grid_data)

func position_player():
	# Posicionar jogador na célula inicial
	var start_cell = grid.get_start_cell()
	current_cell = start_cell
	
	# Atualizar posição do jogador
	update_player_position()

func update_player_position():
	# Converter coordenadas da célula para posição 3D
	var cell_pos = grid.get_cell_position(current_cell)
	player.position = Vector3(cell_pos.x, 0, cell_pos.y)
	
	# Atualizar rotação do jogador
	player.rotation.y = deg_to_rad(player_rotation)

func _input(event):
	if GameStateManager.current_state != GameStateManager.GameState.EXPLORATION:
		return
	
	if event.is_action_pressed("move_forward"):
		move_forward()
	elif event.is_action_pressed("move_backward"):
		move_backward()
	elif event.is_action_pressed("move_left"):
		move_left()
	elif event.is_action_pressed("move_right"):
		move_right()
	elif event.is_action_pressed("turn_left"):
		turn_left()
	elif event.is_action_pressed("turn_right"):
		turn_right()
	elif event.is_action_pressed("interact"):
		interact()
	elif event.is_action_pressed("pause"):
		pause_game()

func move_forward():
	var next_cell = get_next_cell()
	if grid.is_cell_walkable(next_cell):
		current_cell = next_cell
		update_player_position()
		
		# Verificar interações
		check_cell_interactions()

func move_backward():
	var next_cell = get_next_cell(true)
	if grid.is_cell_walkable(next_cell):
		current_cell = next_cell
		update_player_position()
		
		# Verificar interações
		check_cell_interactions()

func move_left():
	var next_cell = get_side_cell(true)
	if grid.is_cell_walkable(next_cell):
		current_cell = next_cell
		update_player_position()
		
		# Verificar interações
		check_cell_interactions()

func move_right():
	var next_cell = get_side_cell(false)
	if grid.is_cell_walkable(next_cell):
		current_cell = next_cell
		update_player_position()
		
		# Verificar interações
		check_cell_interactions()

func turn_left():
	player_rotation = (player_rotation - 90) % 360
	update_player_position()

func turn_right():
	player_rotation = (player_rotation + 90) % 360
	update_player_position()

func get_next_cell(backward: bool = false) -> Vector2i:
	var direction = 1 if not backward else -1
	match player_rotation:
		0: # Norte
			return current_cell + Vector2i(0, -direction)
		90: # Leste
			return current_cell + Vector2i(direction, 0)
		180: # Sul
			return current_cell + Vector2i(0, direction)
		270: # Oeste
			return current_cell + Vector2i(-direction, 0)
	return current_cell

func get_side_cell(left: bool) -> Vector2i:
	var direction = -1 if left else 1
	match player_rotation:
		0: # Norte
			return current_cell + Vector2i(direction, 0)
		90: # Leste
			return current_cell + Vector2i(0, direction)
		180: # Sul
			return current_cell + Vector2i(-direction, 0)
		270: # Oeste
			return current_cell + Vector2i(0, -direction)
	return current_cell

func check_cell_interactions():
	# Verificar interações na célula atual
	var interactions = grid.get_cell_interactions(current_cell)
	
	if interactions.size() > 0:
		# Mostrar prompt de interação
		exploration_hud.show_interaction_prompt(interactions[0])

func interact():
	# Verificar interações na célula atual
	var interactions = grid.get_cell_interactions(current_cell)
	
	if interactions.size() > 0:
		# Iniciar interação
		GameManager.start_interaction(interactions[0])
		GameStateManager.change_state(GameStateManager.GameState.INTERACTION)

func pause_game():
	# Pausar jogo
	GameStateManager.change_state(GameStateManager.GameState.PAUSED)

func _on_game_state_changed(new_state: int):
	match new_state:
		GameStateManager.GameState.EXPLORATION:
			# Mostrar HUD de exploração
			exploration_hud.show()
		GameStateManager.GameState.PAUSED:
			# Pausar exploração
			exploration_hud.hide()
		GameStateManager.GameState.BATTLE:
			# Iniciar batalha
			exploration_hud.hide()
		GameStateManager.GameState.PUZZLE:
			# Iniciar puzzle
			exploration_hud.hide()
		GameStateManager.GameState.DIALOG:
			# Iniciar diálogo
			exploration_hud.hide()
		GameStateManager.GameState.CUTSCENE:
			# Iniciar cutscene
			exploration_hud.hide()
		GameStateManager.GameState.GAME_OVER:
			# Game over
			exploration_hud.hide() 