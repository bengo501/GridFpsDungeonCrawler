extends CharacterBody3D

@export var grid_size: float = 2.0  # Tamanho de cada célula do grid
@export var move_speed: float = 5.0  # Velocidade de movimento
@export var rotation_speed: float = 180.0  # Velocidade de rotação em graus por segundo

var target_position: Vector3
var is_moving: bool = false
var current_grid_position: Vector2

func _ready():
    # Inicializa a posição do grid
    current_grid_position = Vector2(
        round(position.x / grid_size),
        round(position.z / grid_size)
    )
    target_position = position

func _physics_process(delta):
    if is_moving:
        # Move suavemente até a posição alvo
        position = position.lerp(target_position, delta * move_speed)
        
        # Verifica se chegou próximo o suficiente da posição alvo
        if position.distance_to(target_position) < 0.1:
            position = target_position
            is_moving = false

func move_to_grid_position(direction: Vector2):
    if is_moving:
        return
        
    var new_grid_position = current_grid_position + direction
    var new_world_position = Vector3(
        new_grid_position.x * grid_size,
        position.y,
        new_grid_position.y * grid_size
    )
    
    # Aqui você pode adicionar verificação de colisão com paredes
    # Por enquanto, vamos apenas mover
    target_position = new_world_position
    current_grid_position = new_grid_position
    is_moving = true

func _input(event):
    if event.is_action_pressed("move_forward"):
        move_to_grid_position(Vector2(0, -1))
    elif event.is_action_pressed("move_backward"):
        move_to_grid_position(Vector2(0, 1))
    elif event.is_action_pressed("move_left"):
        move_to_grid_position(Vector2(-1, 0))
    elif event.is_action_pressed("move_right"):
        move_to_grid_position(Vector2(1, 0))
    elif event.is_action_pressed("turn_left"):
        rotate_y(deg_to_rad(90))
    elif event.is_action_pressed("turn_right"):
        rotate_y(deg_to_rad(-90)) 