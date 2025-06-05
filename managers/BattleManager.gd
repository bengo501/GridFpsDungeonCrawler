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
    # Aqui você carregaria os dados do inimigo de um arquivo de configuração
    # Por enquanto, vamos usar valores padrão
    current_enemy_health = 100.0
    current_enemy_max_health = 100.0
    current_enemy_damage = 10.0
    current_enemy_defense = 5.0
    current_enemy_skills = ["attack", "defend"]

func load_player_battle_data():
    player_battle_health = GameManager.player_health
    player_battle_max_health = GameManager.player_max_health
    player_battle_damage = 15.0  # Isso deveria vir das estatísticas do jogador
    player_battle_defense = 8.0  # Isso deveria vir das estatísticas do jogador
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

func _on_game_state_changed(new_state: int):
    if new_state != GameStateManager.GameState.IN_BATTLE:
        current_state = BattleState.IDLE 