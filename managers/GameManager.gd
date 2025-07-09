extends Node

# Sinais para comunicação entre managers
signal player_health_changed(new_health: float)
signal player_position_changed(new_position: Vector3)
signal item_collected(item_id: String)
signal enemy_spawned(enemy_id: String, position: Vector3)
signal enemy_defeated(enemy_id: String)
signal puzzle_solved(puzzle_id: String)
signal door_opened(door_id: String)

# Sinais adicionais
signal health_changed(health: float, max_health: float)
signal mp_changed(mp: float, max_mp: float)
signal experience_changed(exp: float, exp_to_next: float)
signal gold_changed(gold: int)
signal level_changed(level: int)

# Informações do jogador
var player_health: float = 100.0
var player_max_health: float = 100.0
var player_mp: float = 50.0
var player_max_mp: float = 50.0
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

# Dados de habilidades e itens
var skill_database = {
	"fireball": {
		"name": "Bola de Fogo",
		"mp_cost": 10,
		"damage": 25,
		"description": "Lança uma bola de fogo no inimigo"
	},
	"heal": {
		"name": "Cura",
		"mp_cost": 15,
		"heal_amount": 30,
		"description": "Restaura pontos de vida"
	},
	"lightning": {
		"name": "Raio",
		"mp_cost": 20,
		"damage": 35,
		"description": "Ataque elétrico poderoso"
	}
}

var item_database = {
	"health_potion": {
		"name": "Poção de Vida",
		"heal_amount": 50,
		"usable_in_battle": true,
		"description": "Restaura 50 pontos de vida"
	},
	"mana_potion": {
		"name": "Poção de Mana",
		"mp_restore": 30,
		"usable_in_battle": true,
		"description": "Restaura 30 pontos de mana"
	},
	"strength_potion": {
		"name": "Poção de Força",
		"damage_boost": 10,
		"duration": 3,
		"usable_in_battle": true,
		"description": "Aumenta o dano por 3 turnos"
	}
}

# Configurações do jogo
var difficulty: int = 1
var volume: float = 1.0

func _ready():
    # Conecta sinais com outros managers
    GameStateManager.state_changed.connect(_on_game_state_changed)
    BattleManager.battle_ended.connect(_on_battle_ended)

func update_player_health(new_health: float):
    player_health = clamp(new_health, 0, player_max_health)
    health_changed.emit(player_health, player_max_health)

func update_player_mp(new_mp: float):
    player_mp = clamp(new_mp, 0, player_max_mp)
    mp_changed.emit(player_mp, player_max_mp)

func heal_player(amount: float):
    update_player_health(player_health + amount)

func restore_mp(amount: float):
    update_player_mp(player_mp + amount)

func use_mp(amount: float) -> bool:
    if player_mp >= amount:
        update_player_mp(player_mp - amount)
        return true
    return false

func get_player_skills() -> Array:
    var skills = []
    for skill_id in player_skills:
        if skill_database.has(skill_id):
            var skill_data = skill_database[skill_id].duplicate()
            skill_data["id"] = skill_id
            skills.append(skill_data)
    return skills

func get_player_items() -> Array:
    var items = []
    var item_counts = {}
    
    # Contar quantidades de cada item
    for item_id in player_inventory:
        if item_counts.has(item_id):
            item_counts[item_id] += 1
        else:
            item_counts[item_id] = 1
    
    # Criar array com dados dos itens
    for item_id in item_counts:
        if item_database.has(item_id):
            var item_data = item_database[item_id].duplicate()
            item_data["id"] = item_id
            item_data["quantity"] = item_counts[item_id]
            items.append(item_data)
    
    return items

func use_item(item_id: String) -> bool:
    if not player_inventory.has(item_id):
        return false
    
    var item_data = item_database.get(item_id, {})
    if item_data.is_empty():
        return false
    
    # Aplicar efeitos do item
    if item_data.has("heal_amount"):
        heal_player(item_data.heal_amount)
    
    if item_data.has("mp_restore"):
        restore_mp(item_data.mp_restore)
    
    # Remover item do inventário
    player_inventory.erase(item_id)
    return true

func learn_skill(skill_id: String):
    if not player_skills.has(skill_id) and skill_database.has(skill_id):
        player_skills.append(skill_id)

func add_item_to_inventory(item_id: String):
    player_inventory.append(item_id)
    item_collected.emit(item_id)

func gain_experience(amount: float):
    player_experience += amount
    var exp_to_next = get_experience_to_next_level()
    experience_changed.emit(player_experience, exp_to_next)
    check_level_up()

func get_experience_to_next_level() -> float:
    return player_level * 100.0

func check_level_up():
    var experience_needed = get_experience_to_next_level()
    if player_experience >= experience_needed:
        player_level += 1
        player_experience -= experience_needed
        player_max_health += 10
        player_max_mp += 5
        player_health = player_max_health
        player_mp = player_max_mp
        level_changed.emit(player_level)
        health_changed.emit(player_health, player_max_health)
        mp_changed.emit(player_mp, player_max_mp)
        
        # Aprender novas habilidades baseado no nível
        match player_level:
            3:
                learn_skill("fireball")
            5:
                learn_skill("heal")
            7:
                learn_skill("lightning")

func add_gold(amount: int):
    player_gold += amount
    gold_changed.emit(player_gold)

func spend_gold(amount: int) -> bool:
    if player_gold >= amount:
        player_gold -= amount
        gold_changed.emit(player_gold)
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

func update_player_position(new_position: Vector3):
    player_position = new_position
    player_position_changed.emit(player_position)

func reset_game():
    reset()

func _on_game_state_changed(new_state: int):
    match new_state:
        GameStateManager.GameState.GAME_OVER:
            reset_game()

func _on_battle_ended():
    # Atualizar informações após batalha
    pass

func reset():
    player_health = player_max_health
    player_mp = player_max_mp
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
    
    # Emitir sinais de atualização
    health_changed.emit(player_health, player_max_health)
    mp_changed.emit(player_mp, player_max_mp)
    experience_changed.emit(player_experience, get_experience_to_next_level())
    gold_changed.emit(player_gold)
    level_changed.emit(player_level)
    
    # Adicionar alguns itens iniciais
    add_item_to_inventory("health_potion")
    add_item_to_inventory("health_potion")
    add_item_to_inventory("mana_potion") 