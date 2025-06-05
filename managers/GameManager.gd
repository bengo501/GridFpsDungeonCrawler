extends Node

# Sinais para comunicação entre managers
signal player_health_changed(new_health: float)
signal player_position_changed(new_position: Vector3)
signal item_collected(item_id: String)
signal enemy_spawned(enemy_id: String, position: Vector3)
signal enemy_defeated(enemy_id: String)
signal puzzle_solved(puzzle_id: String)
signal door_opened(door_id: String)

# Informações do jogador
var player_health: float = 100.0
var player_max_health: float = 100.0
var player_position: Vector3
var player_inventory: Array = []
var player_skills: Array = []
var player_level: int = 1
var player_experience: float = 0.0
var player_gold: int = 0

# Informações do mundo
var current_room: String
var discovered_rooms: Array = []
var opened_doors: Array = []
var collected_items: Array = []
var defeated_enemies: Array = []
var solved_puzzles: Array = []

# Configurações do jogo
var game_difficulty: int = 1
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var master_volume: float = 1.0

func _ready():
    # Conecta sinais com outros managers
    GameStateManager.state_changed.connect(_on_game_state_changed)
    BattleManager.battle_ended.connect(_on_battle_ended)

func update_player_health(new_health: float):
    player_health = clamp(new_health, 0, player_max_health)
    player_health_changed.emit(player_health)

func update_player_position(new_position: Vector3):
    player_position = new_position
    player_position_changed.emit(player_position)

func add_item_to_inventory(item_id: String):
    player_inventory.append(item_id)
    item_collected.emit(item_id)

func add_skill(skill_id: String):
    if not player_skills.has(skill_id):
        player_skills.append(skill_id)

func gain_experience(amount: float):
    player_experience += amount
    check_level_up()

func check_level_up():
    var experience_needed = player_level * 100
    if player_experience >= experience_needed:
        player_level += 1
        player_experience -= experience_needed
        player_max_health += 10
        player_health = player_max_health
        # Adicionar outras recompensas de level up aqui

func add_gold(amount: int):
    player_gold += amount

func spend_gold(amount: int) -> bool:
    if player_gold >= amount:
        player_gold -= amount
        return true
    return false

func mark_room_discovered(room_id: String):
    if not discovered_rooms.has(room_id):
        discovered_rooms.append(room_id)

func mark_door_opened(door_id: String):
    if not opened_doors.has(door_id):
        opened_doors.append(door_id)
        door_opened.emit(door_id)

func mark_enemy_defeated(enemy_id: String):
    if not defeated_enemies.has(enemy_id):
        defeated_enemies.append(enemy_id)
        enemy_defeated.emit(enemy_id)

func mark_puzzle_solved(puzzle_id: String):
    if not solved_puzzles.has(puzzle_id):
        solved_puzzles.append(puzzle_id)
        puzzle_solved.emit(puzzle_id)

func _on_game_state_changed(new_state: int):
    match new_state:
        GameStateManager.GameState.GAME_OVER:
            reset_game()

func _on_battle_ended():
    # Atualizar informações após batalha
    pass

func reset_game():
    player_health = player_max_health
    player_position = Vector3.ZERO
    player_inventory.clear()
    player_skills.clear()
    player_level = 1
    player_experience = 0.0
    player_gold = 0
    discovered_rooms.clear()
    opened_doors.clear()
    collected_items.clear()
    defeated_enemies.clear()
    solved_puzzles.clear() 