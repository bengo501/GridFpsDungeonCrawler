extends CharacterBody3D
class_name Player

@export var move_speed: float = 5.0
@export var grid_size: float = 2.0
@export var turn_speed: float = 180.0

var is_moving: bool = false
var is_turning: bool = false
var target_position: Vector3
var target_rotation: float
var current_direction: Vector3 = Vector3.FORWARD

func _ready():
	target_position = global_position
	target_rotation = rotation.y
	# Inicializar a direção atual baseada na rotação inicial
	update_current_direction()

func _physics_process(delta):
	handle_movement(delta)
	handle_turning(delta)
	handle_input()

func handle_input():
	if is_moving or is_turning:
		return
	
	# Movimento baseado na direção que o jogador está olhando
	if Input.is_action_just_pressed("move_forward"):
		# W ou seta para cima - move para frente (direção que está olhando)
		move_in_direction(current_direction)
	elif Input.is_action_just_pressed("move_backward"):
		# S ou seta para baixo - move para trás (direção oposta)
		move_in_direction(-current_direction)
	elif Input.is_action_just_pressed("move_left"):
		# A ou seta para esquerda - move para a esquerda relativa
		move_in_direction(get_left_direction())
	elif Input.is_action_just_pressed("move_right"):
		# D ou seta para direita - move para a direita relativa
		move_in_direction(get_right_direction())
	
	# Rotação
	elif Input.is_action_just_pressed("turn_left"):
		# Q - girar para a esquerda
		turn(-90)
	elif Input.is_action_just_pressed("turn_right"):
		# E - girar para a direita
		turn(90)
	
	# Interação
	elif Input.is_action_just_pressed("interact"):
		interact_with_object()
	
	# Pausa
	elif Input.is_action_just_pressed("pause"):
		GameStateManager.change_state(GameStateManager.GameState.PAUSED)

func get_left_direction() -> Vector3:
	# Calcula a direção à esquerda baseada na direção atual
	# Rotaciona a direção atual 90 graus para a esquerda
	var left_direction = Vector3(-current_direction.z, 0, current_direction.x)
	return left_direction.normalized()

func get_right_direction() -> Vector3:
	# Calcula a direção à direita baseada na direção atual
	# Rotaciona a direção atual 90 graus para a direita
	var right_direction = Vector3(current_direction.z, 0, -current_direction.x)
	return right_direction.normalized()

func update_current_direction():
	# Atualiza a direção atual baseada na rotação Y
	var angle_rad = rotation.y
	current_direction = Vector3(sin(angle_rad), 0, cos(angle_rad)).normalized()

func move_in_direction(direction: Vector3):
	var new_position = global_position + direction * grid_size
	
	# Verificar se pode se mover para a posição
	if can_move_to(new_position):
		target_position = new_position
		is_moving = true
		GameManager.update_player_position(target_position)
	else:
		print("DEBUG: Movimento bloqueado!")

func can_move_to(pos: Vector3) -> bool:
	# Verificar se a posição está dentro dos limites básicos do mundo
	if pos.x < -10 or pos.x > 20 or pos.z < -10 or pos.z > 20:
		return false
	
	# Tentar obter referência ao grid para verificar colisões
	var grid_node = get_node_or_null("../Grid")
	if grid_node and grid_node.has_method("is_wall"):
		var grid_pos = grid_node.get_grid_position(pos)
		if grid_node.is_wall(grid_pos):
			print("DEBUG: Movimento bloqueado por parede no grid: ", grid_pos)
			return false
	
	# Verificar colisões usando raycast como backup
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 0.5, 0),
		pos + Vector3(0, 0.5, 0)
	)
	query.exclude = [self]
	query.collision_mask = 1  # Apenas objetos na layer 1 (paredes)
	
	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		print("DEBUG: Movimento bloqueado por colisão de raycast")
		return false
	
	return true

func turn(degrees: float):
	target_rotation = rotation.y + deg_to_rad(degrees)
	is_turning = true

func handle_movement(delta: float):
	if not is_moving:
		return
	
	global_position = global_position.move_toward(target_position, move_speed * delta)
	
	if global_position.distance_to(target_position) < 0.1:
		global_position = target_position
		is_moving = false

func handle_turning(delta: float):
	if not is_turning:
		return
	
	var current_y = rotation.y
	var diff = target_rotation - current_y
	
	# Normalizar diferença de ângulo
	while diff > PI:
		diff -= 2 * PI
	while diff < -PI:
		diff += 2 * PI
	
	var turn_amount = turn_speed * delta * deg_to_rad(1)
	
	if abs(diff) < turn_amount:
		rotation.y = target_rotation
		is_turning = false
		# Atualizar direção atual após completar a rotação
		update_current_direction()
	else:
		rotation.y += sign(diff) * turn_amount
		# Atualizar direção atual durante a rotação
		update_current_direction()

func interact_with_object():
	# Procurar por objetos interagíveis próximos
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position, 
		global_position + current_direction * grid_size
	)
	query.collision_mask = 2  # Interactable layer
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		var collider = result.collider
		if collider.has_method("interact"):
			collider.interact()

func is_player() -> bool:
	return true

func take_damage(amount: float):
	GameManager.update_player_health(GameManager.player_health - amount)
	
	if GameManager.player_health <= 0:
		die()

func die():
	GameStateManager.change_state(GameStateManager.GameState.GAME_OVER)

func start_battle(enemy_id: String):
	BattleManager.start_battle(enemy_id)
	GameStateManager.change_state(GameStateManager.GameState.IN_BATTLE) 