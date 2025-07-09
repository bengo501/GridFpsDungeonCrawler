extends Node

# Sinais para comunicação entre managers
signal battle_started(enemy_id: String)
signal battle_ended(victory: bool)
signal turn_changed(turn_number: int, current_actor: String)
signal damage_dealt(attacker: String, target: String, amount: float)
signal enemy_defeated(enemy_id: String)
signal player_defeated

# Estados da batalha
enum BattleState {
    IDLE,
    PLAYER_TURN,
    ENEMY_TURN,
    VICTORY,
    DEFEAT
}

# Informações da batalha atual
var current_state: BattleState = BattleState.IDLE
var current_turn: int = 0
var current_enemy_id: String
var current_enemy_health: float
var current_enemy_max_health: float
var current_enemy_damage: float
var current_enemy_defense: float
var current_enemy_skills: Array = []

# Informações do jogador em batalha
var player_battle_health: float
var player_battle_max_health: float
var player_battle_damage: float
var player_battle_defense: float
var player_battle_skills: Array = []

# Constantes para turnos
const PLAYER_TURN = 1
const ENEMY_TURN = 2

# Informações adicionais
var enemy_name: String = ""
var player_health: float
var player_max_health: float
var enemy_health: float
var enemy_max_health: float

func _ready():
    # Conecta sinais com outros managers
    GameStateManager.state_changed.connect(_on_game_state_changed)

func start_battle(enemy_id: String):
    current_state = BattleState.PLAYER_TURN
    current_turn = 1
    current_enemy_id = enemy_id
    
    # Carrega informações do inimigo
    load_enemy_data(enemy_id)
    
    # Carrega informações do jogador
    load_player_battle_data()
    
    battle_started.emit(enemy_id)
    turn_changed.emit(current_turn, "player")

func load_enemy_data(enemy_id: String):
    # Dados de inimigos baseados no ID
    var enemy_data = {
        "goblin": {
            "name": "Goblin",
            "health": 80,
            "damage": 12,
            "defense": 3
        },
        "orc": {
            "name": "Orc",
            "health": 120,
            "damage": 18,
            "defense": 8
        },
        "skeleton": {
            "name": "Esqueleto",
            "health": 100,
            "damage": 15,
            "defense": 5
        }
    }
    
    var data = enemy_data.get(enemy_id, enemy_data["goblin"])
    enemy_name = data.name
    current_enemy_health = data.health
    current_enemy_max_health = data.health
    enemy_health = current_enemy_health
    enemy_max_health = current_enemy_max_health
    current_enemy_damage = data.damage
    current_enemy_defense = data.defense

func load_player_battle_data():
    player_battle_health = GameManager.player_health
    player_battle_max_health = GameManager.player_max_health
    player_health = player_battle_health
    player_max_health = player_battle_max_health
    player_battle_damage = 15.0 + (GameManager.player_level * 2)
    player_battle_defense = 8.0 + GameManager.player_level
    player_battle_skills = GameManager.player_skills

func player_attack():
    if current_state != BattleState.PLAYER_TURN:
        return
    
    var damage = calculate_damage(player_battle_damage, current_enemy_defense)
    current_enemy_health -= damage
    damage_dealt.emit("player", current_enemy_id, damage)
    
    if current_enemy_health <= 0:
        end_battle(true)
    else:
        start_enemy_turn()

func enemy_attack():
    if current_state != BattleState.ENEMY_TURN:
        return
    
    var damage = calculate_damage(current_enemy_damage, player_battle_defense)
    player_battle_health -= damage
    damage_dealt.emit(current_enemy_id, "player", damage)
    
    if player_battle_health <= 0:
        end_battle(false)
    else:
        start_player_turn()

func calculate_damage(attack: float, defense: float) -> float:
    var base_damage = attack - (defense * 0.5)
    var random_factor = randf_range(0.8, 1.2)
    return max(1, base_damage * random_factor)

func start_player_turn():
    current_state = BattleState.PLAYER_TURN
    turn_changed.emit(current_turn, "player")

func start_enemy_turn():
    current_state = BattleState.ENEMY_TURN
    turn_changed.emit(current_turn, "enemy")
    # Simula um pequeno delay antes do ataque do inimigo
    await get_tree().create_timer(1.0).timeout
    enemy_attack()

func end_battle(victory: bool):
    current_state = BattleState.IDLE
    
    if victory:
        GameManager.mark_enemy_defeated(current_enemy_id)
        GameManager.gain_experience(50)  # Experiência base por derrotar um inimigo
        enemy_defeated.emit(current_enemy_id)
    else:
        player_defeated.emit()
    
    battle_ended.emit(victory)

func use_skill(skill_id: String):
    if current_state != BattleState.PLAYER_TURN:
        return
    
    # Implementar lógica de skills aqui
    pass

func player_use_skill(skill: Dictionary):
    if current_state != BattleState.PLAYER_TURN:
        return
    
    # Verificar se o jogador tem MP suficiente
    if not GameManager.use_mp(skill.mp_cost):
        return
    
    # Aplicar efeitos da habilidade
    if skill.has("damage"):
        var damage = calculate_damage(skill.damage, current_enemy_defense)
        current_enemy_health -= damage
        enemy_health = current_enemy_health
        damage_dealt.emit("player", current_enemy_id, damage)
        
        if current_enemy_health <= 0:
            end_battle(true)
            return
    
    if skill.has("heal_amount"):
        GameManager.heal_player(skill.heal_amount)
        player_battle_health = GameManager.player_health
        player_health = player_battle_health
    
    end_player_turn()

func player_use_item(item: Dictionary):
    if current_state != BattleState.PLAYER_TURN:
        return
    
    # Usar o item
    if GameManager.use_item(item.id):
        # Atualizar stats de batalha
        player_battle_health = GameManager.player_health
        player_health = player_battle_health
        
        end_player_turn()

func attempt_flee() -> bool:
    if current_state != BattleState.PLAYER_TURN:
        return false
    
    # 70% de chance de fuga bem-sucedida
    var flee_chance = 0.7
    var success = randf() < flee_chance
    
    if success:
        current_state = BattleState.IDLE
        return true
    else:
        end_player_turn()
        return false

func end_player_turn():
    current_turn += 1
    start_enemy_turn()

func _on_game_state_changed(new_state: int):
    if new_state != GameStateManager.GameState.IN_BATTLE:
        current_state = BattleState.IDLE 