extends Node

# Sinais para comunicação entre managers
signal save_created(save_id: String)
signal save_loaded(save_id: String)
signal save_deleted(save_id: String)
signal save_error(error_message: String)

# Estrutura de dados para o save
var save_data: Dictionary = {
    "player": {
        "health": 100.0,
        "max_health": 100.0,
        "position": Vector3.ZERO,
        "inventory": [],
        "skills": [],
        "level": 1,
        "experience": 0.0,
        "gold": 0
    },
    "world": {
        "current_room": "",
        "discovered_rooms": [],
        "opened_doors": [],
        "collected_items": [],
        "defeated_enemies": [],
        "solved_puzzles": []
    },
    "settings": {
        "game_difficulty": 1,
        "music_volume": 1.0,
        "sfx_volume": 1.0,
        "master_volume": 1.0
    },
    "metadata": {
        "save_date": "",
        "play_time": 0.0,
        "version": "1.0"
    }
}

var current_save_id: String
var save_directory: String = "user://saves/"

func _ready():
    # Cria o diretório de saves se não existir
    if not DirAccess.dir_exists_absolute(save_directory):
        DirAccess.make_dir_absolute(save_directory)

func create_save(save_id: String) -> bool:
    current_save_id = save_id
    
    # Atualiza os dados do save com as informações atuais do jogo
    update_save_data()
    
    # Adiciona metadados
    save_data.metadata.save_date = Time.get_datetime_string_from_system()
    
    # Salva o arquivo
    var save_path = save_directory + save_id + ".save"
    var save_file = FileAccess.open(save_path, FileAccess.WRITE)
    
    if save_file == null:
        save_error.emit("Erro ao criar arquivo de save")
        return false
    
    save_file.store_var(save_data)
    save_created.emit(save_id)
    return true

func load_save(save_id: String) -> bool:
    current_save_id = save_id
    var save_path = save_directory + save_id + ".save"
    
    if not FileAccess.file_exists(save_path):
        save_error.emit("Arquivo de save não encontrado")
        return false
    
    var save_file = FileAccess.open(save_path, FileAccess.READ)
    if save_file == null:
        save_error.emit("Erro ao abrir arquivo de save")
        return false
    
    save_data = save_file.get_var()
    apply_save_data()
    save_loaded.emit(save_id)
    return true

func delete_save(save_id: String) -> bool:
    var save_path = save_directory + save_id + ".save"
    
    if not FileAccess.file_exists(save_path):
        save_error.emit("Arquivo de save não encontrado")
        return false
    
    var error = DirAccess.remove_absolute(save_path)
    if error != OK:
        save_error.emit("Erro ao deletar arquivo de save")
        return false
    
    save_deleted.emit(save_id)
    return true

func get_save_list() -> Array:
    var saves = []
    var dir = DirAccess.open(save_directory)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".save"):
                saves.append(file_name.get_basename())
            file_name = dir.get_next()
    
    return saves

func update_save_data():
    # Atualiza dados do jogador
    save_data.player.health = GameManager.player_health
    save_data.player.max_health = GameManager.player_max_health
    save_data.player.position = GameManager.player_position
    save_data.player.inventory = GameManager.player_inventory
    save_data.player.skills = GameManager.player_skills
    save_data.player.level = GameManager.player_level
    save_data.player.experience = GameManager.player_experience
    save_data.player.gold = GameManager.player_gold
    
    # Atualiza dados do mundo
    save_data.world.current_room = GameManager.current_room
    save_data.world.discovered_rooms = GameManager.discovered_rooms
    save_data.world.opened_doors = GameManager.opened_doors
    save_data.world.collected_items = GameManager.collected_items
    save_data.world.defeated_enemies = GameManager.defeated_enemies
    save_data.world.solved_puzzles = GameManager.solved_puzzles
    
    # Atualiza configurações
    save_data.settings.game_difficulty = GameManager.game_difficulty
    save_data.settings.music_volume = GameManager.music_volume
    save_data.settings.sfx_volume = GameManager.sfx_volume
    save_data.settings.master_volume = GameManager.master_volume

func apply_save_data():
    # Aplica dados do jogador
    GameManager.player_health = save_data.player.health
    GameManager.player_max_health = save_data.player.max_health
    GameManager.player_position = save_data.player.position
    GameManager.player_inventory = save_data.player.inventory
    GameManager.player_skills = save_data.player.skills
    GameManager.player_level = save_data.player.level
    GameManager.player_experience = save_data.player.experience
    GameManager.player_gold = save_data.player.gold
    
    # Aplica dados do mundo
    GameManager.current_room = save_data.world.current_room
    GameManager.discovered_rooms = save_data.world.discovered_rooms
    GameManager.opened_doors = save_data.world.opened_doors
    GameManager.collected_items = save_data.world.collected_items
    GameManager.defeated_enemies = save_data.world.defeated_enemies
    GameManager.solved_puzzles = save_data.world.solved_puzzles
    
    # Aplica configurações
    GameManager.game_difficulty = save_data.settings.game_difficulty
    GameManager.music_volume = save_data.settings.music_volume
    GameManager.sfx_volume = save_data.settings.sfx_volume
    GameManager.master_volume = save_data.settings.master_volume 