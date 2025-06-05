extends Node3D

@export var grid_size: float = 2.0  # Tamanho de cada célula do grid
@export var map_size: Vector2i = Vector2i(10, 10)  # Tamanho do mapa em células

# Tipos de células
enum CellType {
    FLOOR,
    WALL
}

var grid: Array[Array] = []
var wall_scene: PackedScene
var floor_scene: PackedScene

func _ready():
    # Carrega as cenas das paredes e chão
    wall_scene = load("res://Wall.tscn")
    floor_scene = load("res://Floor.tscn")
    
    initialize_grid()
    create_dungeon()
    instantiate_dungeon()

func initialize_grid():
    # Inicializa o grid com chão
    grid.clear()
    for x in range(map_size.x):
        var column: Array = []
        for y in range(map_size.y):
            column.append(CellType.FLOOR)
        grid.append(column)

func create_dungeon():
    # Cria paredes nas bordas
    for x in range(map_size.x):
        grid[x][0] = CellType.WALL
        grid[x][map_size.y - 1] = CellType.WALL
    
    for y in range(map_size.y):
        grid[0][y] = CellType.WALL
        grid[map_size.x - 1][y] = CellType.WALL
    
    # Adiciona algumas paredes internas aleatórias
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    
    for x in range(1, map_size.x - 1):
        for y in range(1, map_size.y - 1):
            if rng.randf() < 0.2:  # 20% de chance de ser parede
                grid[x][y] = CellType.WALL

func instantiate_dungeon():
    # Remove todos os nós filhos existentes
    for child in get_children():
        child.queue_free()
    
    # Instancia as paredes e o chão
    for x in range(map_size.x):
        for y in range(map_size.y):
            var world_pos = get_world_position(Vector2(x, y))
            
            if grid[x][y] == CellType.WALL:
                var wall = wall_scene.instantiate()
                wall.position = world_pos
                add_child(wall)
            else:
                var floor = floor_scene.instantiate()
                floor.position = world_pos
                add_child(floor)

func is_wall(grid_position: Vector2i) -> bool:
    if grid_position.x < 0 or grid_position.x >= map_size.x or \
       grid_position.y < 0 or grid_position.y >= map_size.y:
        return true
    return grid[grid_position.x][grid_position.y] == CellType.WALL

func get_world_position(grid_position: Vector2) -> Vector3:
    return Vector3(
        grid_position.x * grid_size,
        0,
        grid_position.y * grid_size
    )

func get_grid_position(world_position: Vector3) -> Vector2:
    return Vector2(
        round(world_position.x / grid_size),
        round(world_position.z / grid_size)
    ) 