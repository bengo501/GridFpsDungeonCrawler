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
        "mp": 50.0,
        "max_mp": 50.0,
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
        "difficulty": 1,
        "volume": 1.0
    },
    "metadata": {
        "save_name": "",
        "save_date": "",
        "date_created": "",
        "play_time": "00:00",
        "version": "1.0"
    }
}

var current_save_id: String
var save_directory: String = "user://saves/"

func _ready():
    # Cria o diretório de saves se não existir
    if not DirAccess.dir_exists_absolute(save_directory):
        DirAccess.make_dir_absolute(save_directory)

func get_save_list() -> Array:
    var saves = []
    var dir = DirAccess.open(save_directory)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".save"):
                var save_info = get_save_info(file_name.get_basename())
                if save_info:
                    saves.append(save_info)
            file_name = dir.get_next()
    
    return saves

func get_save_info(save_id: String) -> Dictionary:
    var save_path = save_directory + save_id + ".save"
    
    if not FileAccess.file_exists(save_path):
        return {}
    
    var save_file = FileAccess.open(save_path, FileAccess.READ)
    if save_file == null:
        return {}
    
    var data = save_file.get_var()
    save_file.close()
    
    return {
        "id": save_id,
        "save_name": data.metadata.get("save_name", "Save " + save_id),
        "date_created": data.metadata.get("date_created", ""),
        "play_time": data.metadata.get("play_time", "00:00"),
        "level": data.player.get("level", 1)
    }

func create_save(save_name: String) -> bool:
    var save_id = "save_" + str(Time.get_unix_time_from_system())
    current_save_id = save_id
    
    # Atualiza os dados do save com as informações atuais do jogo
    update_save_data()
    
    # Adiciona metadados
    save_data.metadata.save_name = save_name
    save_data.metadata.save_date = Time.get_datetime_string_from_system()
    save_data.metadata.date_created = Time.get_datetime_string_from_system()
    save_data.metadata.play_time = format_time(0) # TODO: implementar tempo de jogo
    
    # Salva o arquivo
    var save_path = save_directory + save_id + ".save"
    var save_file = FileAccess.open(save_path, FileAccess.WRITE)
    
    if save_file == null:
        save_error.emit("Erro ao criar arquivo de save")
        return false
    
    save_file.store_var(save_data)
    save_file.close()
    save_created.emit(save_id)
    return true

func load_save(save_index: int) -> bool:
    var saves = get_save_list()
    if save_index < 0 or save_index >= saves.size():
        save_error.emit("Índice de save inválido")
        return false
    
    var save_info = saves[save_index]
    return load_save_by_id(save_info.id)

func load_save_by_id(save_id: String) -> bool:
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
    save_file.close()
    apply_save_data()
    save_loaded.emit(save_id)
    return true

func delete_save(save_index: int) -> bool:
    var saves = get_save_list()
    if save_index < 0 or save_index >= saves.size():
        save_error.emit("Índice de save inválido")
        return false
    
    var save_info = saves[save_index]
    var save_path = save_directory + save_info.id + ".save"
    
    if not FileAccess.file_exists(save_path):
        save_error.emit("Arquivo de save não encontrado")
        return false
    
    var error = DirAccess.remove_absolute(save_path)
    if error != OK:
        save_error.emit("Erro ao deletar arquivo de save")
        return false
    
    save_deleted.emit(save_info.id)
    return true

func format_time(seconds: int) -> String:
    var minutes = seconds / 60
    var remaining_seconds = seconds % 60
    return "%02d:%02d" % [minutes, remaining_seconds]

func update_save_data():
    # Atualiza dados do jogador
    save_data.player.health = GameManager.player_health
    save_data.player.max_health = GameManager.player_max_health
    save_data.player.mp = GameManager.player_mp
    save_data.player.max_mp = GameManager.player_max_mp
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
    save_data.settings.difficulty = GameManager.difficulty
    save_data.settings.volume = GameManager.volume

func apply_save_data():
    # Aplica dados do jogador
    GameManager.player_health = save_data.player.health
    GameManager.player_max_health = save_data.player.max_health
    GameManager.player_mp = save_data.player.get("mp", 50.0)
    GameManager.player_max_mp = save_data.player.get("max_mp", 50.0)
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
    GameManager.difficulty = save_data.settings.get("difficulty", 1)
    GameManager.volume = save_data.settings.get("volume", 1.0)
    
    # Emitir sinais de atualização
    GameManager.health_changed.emit(GameManager.player_health, GameManager.player_max_health)
    GameManager.mp_changed.emit(GameManager.player_mp, GameManager.player_max_mp)
    GameManager.experience_changed.emit(GameManager.player_experience, GameManager.get_experience_to_next_level())
    GameManager.gold_changed.emit(GameManager.player_gold)
    GameManager.level_changed.emit(GameManager.player_level) 