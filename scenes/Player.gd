extends Node3D

# Referências
@onready var model = $Model
@onready var weapon = $Model/Weapon
@onready var animation_player = $AnimationPlayer

# Variáveis
var health = 100
var max_health = 100
var attack = 10
var defense = 5
var level = 1
var experience = 0
var experience_to_next_level = 100
var inventory = []
var equipment = {
	"weapon": null,
	"armor": null,
	"accessory": null
}

func _ready():
	# Conectar sinais
	GameManager.player_stats_updated.connect(_on_player_stats_updated)
	GameManager.player_inventory_updated.connect(_on_player_inventory_updated)
	GameManager.player_equipment_updated.connect(_on_player_equipment_updated)
	
	# Carregar dados do jogador
	load_player_data()

func load_player_data():
	# Carregar dados do jogador
	var player_data = GameManager.player_data
	
	# Aplicar dados
	health = player_data.get("health", max_health)
	max_health = player_data.get("max_health", 100)
	attack = player_data.get("attack", 10)
	defense = player_data.get("defense", 5)
	level = player_data.get("level", 1)
	experience = player_data.get("experience", 0)
	experience_to_next_level = player_data.get("experience_to_next_level", 100)
	inventory = player_data.get("inventory", [])
	equipment = player_data.get("equipment", {
		"weapon": null,
		"armor": null,
		"accessory": null
	})

func take_damage(amount: int) -> int:
	# Calcular dano real
	var real_damage = max(1, amount - defense)
	
	# Aplicar dano
	health = max(0, health - real_damage)
	
	# Atualizar dados
	GameManager.update_player_stats({
		"health": health
	})
	
	return real_damage

func heal(amount: int) -> int:
	# Calcular cura real
	var real_heal = min(amount, max_health - health)
	
	# Aplicar cura
	health = min(max_health, health + real_heal)
	
	# Atualizar dados
	GameManager.update_player_stats({
		"health": health
	})
	
	return real_heal

func add_experience(amount: int) -> bool:
	# Adicionar experiência
	experience += amount
	
	# Verificar level up
	var leveled_up = false
	while experience >= experience_to_next_level:
		level_up()
		leveled_up = true
	
	# Atualizar dados
	GameManager.update_player_stats({
		"experience": experience,
		"experience_to_next_level": experience_to_next_level
	})
	
	return leveled_up

func level_up():
	# Aumentar nível
	level += 1
	
	# Aumentar atributos
	max_health += 10
	health = max_health
	attack += 2
	defense += 1
	
	# Calcular próxima experiência
	experience_to_next_level = int(experience_to_next_level * 1.5)
	
	# Atualizar dados
	GameManager.update_player_stats({
		"level": level,
		"max_health": max_health,
		"health": health,
		"attack": attack,
		"defense": defense,
		"experience_to_next_level": experience_to_next_level
	})

func add_item(item: Dictionary) -> bool:
	# Verificar se inventário está cheio
	if inventory.size() >= 20:
		return false
	
	# Adicionar item
	inventory.append(item)
	
	# Atualizar dados
	GameManager.update_player_inventory(inventory)
	
	return true

func remove_item(item_index: int) -> Dictionary:
	# Verificar índice
	if item_index < 0 or item_index >= inventory.size():
		return {}
	
	# Remover item
	var item = inventory[item_index]
	inventory.remove_at(item_index)
	
	# Atualizar dados
	GameManager.update_player_inventory(inventory)
	
	return item

func equip_item(item_index: int) -> bool:
	# Verificar índice
	if item_index < 0 or item_index >= inventory.size():
		return false
	
	# Obter item
	var item = inventory[item_index]
	
	# Verificar tipo
	if not item.has("type") or not item.has("slot"):
		return false
	
	# Desequipar item atual
	if equipment[item["slot"]] != null:
		inventory.append(equipment[item["slot"]])
	
	# Equipar novo item
	equipment[item["slot"]] = item
	inventory.remove_at(item_index)
	
	# Atualizar atributos
	update_equipment_stats()
	
	# Atualizar dados
	GameManager.update_player_inventory(inventory)
	GameManager.update_player_equipment(equipment)
	
	return true

func unequip_item(slot: String) -> bool:
	# Verificar slot
	if not equipment.has(slot) or equipment[slot] == null:
		return false
	
	# Verificar se inventário está cheio
	if inventory.size() >= 20:
		return false
	
	# Desequipar item
	var item = equipment[slot]
	equipment[slot] = null
	inventory.append(item)
	
	# Atualizar atributos
	update_equipment_stats()
	
	# Atualizar dados
	GameManager.update_player_inventory(inventory)
	GameManager.update_player_equipment(equipment)
	
	return true

func update_equipment_stats():
	# Resetar atributos base
	max_health = 100 + (level - 1) * 10
	attack = 10 + (level - 1) * 2
	defense = 5 + (level - 1)
	
	# Aplicar bônus dos equipamentos
	for item in equipment.values():
		if item != null:
			if item.has("health_bonus"):
				max_health += item["health_bonus"]
			if item.has("attack_bonus"):
				attack += item["attack_bonus"]
			if item.has("defense_bonus"):
				defense += item["defense_bonus"]
	
	# Ajustar vida atual
	health = min(health, max_health)
	
	# Atualizar dados
	GameManager.update_player_stats({
		"max_health": max_health,
		"health": health,
		"attack": attack,
		"defense": defense
	})

func _on_player_stats_updated(stats: Dictionary):
	# Atualizar estatísticas
	if stats.has("health"):
		health = stats["health"]
	if stats.has("max_health"):
		max_health = stats["max_health"]
	if stats.has("attack"):
		attack = stats["attack"]
	if stats.has("defense"):
		defense = stats["defense"]
	if stats.has("level"):
		level = stats["level"]
	if stats.has("experience"):
		experience = stats["experience"]
	if stats.has("experience_to_next_level"):
		experience_to_next_level = stats["experience_to_next_level"]

func _on_player_inventory_updated(new_inventory: Array):
	# Atualizar inventário
	inventory = new_inventory

func _on_player_equipment_updated(new_equipment: Dictionary):
	# Atualizar equipamentos
	equipment = new_equipment
	
	# Atualizar atributos
	update_equipment_stats() 