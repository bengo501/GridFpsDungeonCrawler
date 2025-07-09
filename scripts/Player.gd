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

func _physics_process(delta):
	handle_movement(delta)
	handle_turning(delta)
	handle_input()

func handle_input():
	if is_moving or is_turning:
		return
	
	# Movimento
	if Input.is_action_just_pressed("move_forward"):
		move_in_direction(current_direction)
	elif Input.is_action_just_pressed("move_backward"):
		move_in_direction(-current_direction)
	elif Input.is_action_just_pressed("move_left"):
		move_in_direction(-transform.basis.x)
	elif Input.is_action_just_pressed("move_right"):
		move_in_direction(transform.basis.x)
	
	# Rotação
	elif Input.is_action_just_pressed("turn_left"):
		turn(-90)
	elif Input.is_action_just_pressed("turn_right"):
		turn(90)
	
	# Interação
	elif Input.is_action_just_pressed("interact"):
		interact_with_object()
	
	# Pausa
	elif Input.is_action_just_pressed("pause"):
		GameStateManager.change_state(GameStateManager.GameState.PAUSE_MENU)

func move_in_direction(direction: Vector3):
	var new_position = global_position + direction * grid_size
	
	# Verificar se pode se mover para a posição
	if can_move_to(new_position):
		target_position = new_position
		is_moving = true
		GameManager.update_player_position(target_position)

func can_move_to(pos: Vector3) -> bool:
	# Verificar colisões
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, pos)
	query.collision_mask = 4  # Wall layer
	var result = space_state.intersect_ray(query)
	
	return result.is_empty()

func turn(degrees: float):
	target_rotation = rotation.y + deg_to_rad(degrees)
	is_turning = true
	
	# Atualizar direção atual
	var angle_rad = target_rotation
	current_direction = Vector3(sin(angle_rad), 0, cos(angle_rad))

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
	else:
		rotation.y += sign(diff) * turn_amount

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