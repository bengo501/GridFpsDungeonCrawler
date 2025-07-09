extends CharacterBody3D
class_name Enemy

@export var enemy_id: String = "goblin"
@export var enemy_name: String = "Goblin"
@export var patrol_range: float = 4.0
@export var detection_range: float = 3.0
@export var move_speed: float = 2.0
@export var grid_size: float = 2.0

var home_position: Vector3
var is_moving: bool = false
var target_position: Vector3
var player_detected: bool = false
var player_ref: Player

enum EnemyState {
	IDLE,
	PATROL,
	CHASE,
	BATTLE
}

var current_state: EnemyState = EnemyState.IDLE
var patrol_timer: float = 0.0
var patrol_direction: Vector3 = Vector3.FORWARD

func _ready():
	home_position = global_position
	target_position = global_position
	
	# Configurar collision layers
	collision_layer = 8  # Enemy layer
	collision_mask = 1   # Player layer
	
	# Procurar pelo player
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	update_state(delta)
	handle_movement(delta)
	check_player_detection()

func update_state(delta: float):
	match current_state:
		EnemyState.IDLE:
			patrol_timer += delta
			if patrol_timer >= 2.0:
				current_state = EnemyState.PATROL
				patrol_timer = 0.0
		
		EnemyState.PATROL:
			if not is_moving:
				patrol()
			
			patrol_timer += delta
			if patrol_timer >= 3.0:
				current_state = EnemyState.IDLE
				patrol_timer = 0.0
		
		EnemyState.CHASE:
			if player_ref and not is_moving:
				chase_player()

func patrol():
	# Movimento aleatório dentro do range de patrulha
	var random_dir = Vector3(
		randf_range(-1, 1),
		0,
		randf_range(-1, 1)
	).normalized()
	
	var new_pos = home_position + random_dir * patrol_range
	
	# Verificar se a posição está dentro do range
	if home_position.distance_to(new_pos) <= patrol_range:
		if can_move_to(new_pos):
			move_to(new_pos)

func chase_player():
	if not player_ref:
		return
	
	var direction = (player_ref.global_position - global_position).normalized()
	var new_pos = global_position + direction * grid_size
	
	if can_move_to(new_pos):
		move_to(new_pos)

func move_to(pos: Vector3):
	target_position = pos
	is_moving = true

func can_move_to(pos: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, pos)
	query.collision_mask = 4  # Wall layer
	var result = space_state.intersect_ray(query)
	
	return result.is_empty()

func handle_movement(delta: float):
	if not is_moving:
		return
	
	global_position = global_position.move_toward(target_position, move_speed * delta)
	
	if global_position.distance_to(target_position) < 0.1:
		global_position = target_position
		is_moving = false

func check_player_detection():
	if not player_ref:
		return
	
	var distance = global_position.distance_to(player_ref.global_position)
	
	if distance <= detection_range:
		if not player_detected:
			player_detected = true
			current_state = EnemyState.CHASE
	elif distance > detection_range * 1.5:
		if player_detected:
			player_detected = false
			current_state = EnemyState.IDLE
	
	# Verificar colisão com player para iniciar batalha
	if distance <= 1.0 and current_state != EnemyState.BATTLE:
		start_battle()

func start_battle():
	current_state = EnemyState.BATTLE
	if player_ref:
		player_ref.start_battle(enemy_id)

func defeat():
	# Remover inimigo da cena
	GameManager.mark_enemy_defeated(enemy_id)
	queue_free()

func _on_body_entered(body):
	if body.is_player():
		start_battle() 