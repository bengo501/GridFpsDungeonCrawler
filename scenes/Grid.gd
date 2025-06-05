extends Node3D

# Referências
@onready var cells = $Cells
@onready var walls = $Walls
@onready var doors = $Doors
@onready var interactables = $Interactables

# Variáveis
var grid_data = {}
var grid_size = Vector2i.ZERO
var start_cell = Vector2i.ZERO
var cell_size = 2.0
var cell_interactions = {}

func setup_grid(data: Dictionary):
	# Salvar dados do grid
	grid_data = data
	grid_size = Vector2i(data.get("width", 0), data.get("height", 0))
	start_cell = Vector2i(data.get("start_x", 0), data.get("start_y", 0))
	
	# Limpar grid
	clear_grid()
	
	# Construir grid
	build_grid()

func clear_grid():
	# Limpar nós
	for child in cells.get_children():
		child.queue_free()
	
	for child in walls.get_children():
		child.queue_free()
	
	for child in doors.get_children():
		child.queue_free()
	
	for child in interactables.get_children():
		child.queue_free()
	
	# Limpar dados
	cell_interactions.clear()

func build_grid():
	# Construir células
	build_cells()
	
	# Construir paredes
	build_walls()
	
	# Construir portas
	build_doors()
	
	# Construir interativos
	build_interactables()

func build_cells():
	# Criar células do grid
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell = create_cell(Vector2i(x, y))
			cells.add_child(cell)

func build_walls():
	# Criar paredes do grid
	for wall_data in grid_data.get("walls", []):
		var wall = create_wall(wall_data)
		walls.add_child(wall)

func build_doors():
	# Criar portas do grid
	for door_data in grid_data.get("doors", []):
		var door = create_door(door_data)
		doors.add_child(door)

func build_interactables():
	# Criar interativos do grid
	for interactable_data in grid_data.get("interactables", []):
		var interactable = create_interactable(interactable_data)
		interactables.add_child(interactable)
		
		# Adicionar interação
		var cell = Vector2i(interactable_data.get("x", 0), interactable_data.get("y", 0))
		if not cell_interactions.has(cell):
			cell_interactions[cell] = []
		cell_interactions[cell].append(interactable_data)

func create_cell(pos: Vector2i) -> Node3D:
	var cell = Node3D.new()
	cell.name = "Cell_%d_%d" % [pos.x, pos.y]
	cell.position = get_cell_position(pos)
	return cell

func create_wall(data: Dictionary) -> Node3D:
	var wall = Node3D.new()
	wall.name = "Wall_%d_%d" % [data.get("x", 0), data.get("y", 0)]
	wall.position = get_cell_position(Vector2i(data.get("x", 0), data.get("y", 0)))
	return wall

func create_door(data: Dictionary) -> Node3D:
	var door = Node3D.new()
	door.name = "Door_%d_%d" % [data.get("x", 0), data.get("y", 0)]
	door.position = get_cell_position(Vector2i(data.get("x", 0), data.get("y", 0)))
	return door

func create_interactable(data: Dictionary) -> Node3D:
	var interactable = Node3D.new()
	interactable.name = "Interactable_%d_%d" % [data.get("x", 0), data.get("y", 0)]
	interactable.position = get_cell_position(Vector2i(data.get("x", 0), data.get("y", 0)))
	return interactable

func get_cell_position(cell: Vector2i) -> Vector3:
	return Vector3(cell.x * cell_size, 0, cell.y * cell_size)

func get_start_cell() -> Vector2i:
	return start_cell

func is_cell_walkable(cell: Vector2i) -> bool:
	# Verificar se célula está dentro do grid
	if cell.x < 0 or cell.x >= grid_size.x or cell.y < 0 or cell.y >= grid_size.y:
		return false
	
	# Verificar se célula tem parede
	for wall in walls.get_children():
		var wall_pos = Vector2i(wall.position.x / cell_size, wall.position.z / cell_size)
		if wall_pos == cell:
			return false
	
	return true

func get_cell_interactions(cell: Vector2i) -> Array:
	return cell_interactions.get(cell, []) 