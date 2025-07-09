extends Interactable
class_name Chest

@export var chest_contents: Array[String] = ["health_potion"]
@export var gold_amount: int = 50
@export var is_locked: bool = false
@export var required_key: String = ""

func _ready():
	super._ready()
	interaction_title = "Baú"
	interaction_description = "Um baú de madeira resistente."
	
	if is_locked:
		interaction_options = ["Examinar", "Tentar Abrir"]
	else:
		interaction_options = ["Examinar", "Abrir"]
	
	one_time_use = true

func handle_interaction_option(option: String):
	match option:
		"Examinar":
			if has_been_used:
				show_dialog("Um baú vazio. Você já pegou tudo que havia aqui.")
			elif is_locked:
				show_dialog("Um baú trancado. Você precisa de uma chave para abri-lo.")
			else:
				show_dialog("Um baú de madeira. Parece conter algo valioso.")
		
		"Abrir":
			if not is_locked:
				open_chest()
			else:
				show_dialog("O baú está trancado!")
		
		"Tentar Abrir":
			if is_locked:
				if required_key != "" and GameManager.player_inventory.has(required_key):
					is_locked = false
					show_dialog("Você usa a chave para abrir o baú!")
					open_chest()
				else:
					show_dialog("O baú está trancado. Você precisa de uma chave.")
			else:
				open_chest()

func open_chest():
	var rewards = []
	
	# Adicionar itens ao inventário
	for item_id in chest_contents:
		GameManager.add_item_to_inventory(item_id)
		var item_name = GameManager.item_database.get(item_id, {}).get("name", item_id)
		rewards.append(item_name)
	
	# Adicionar ouro
	if gold_amount > 0:
		GameManager.add_gold(gold_amount)
		rewards.append("%d ouro" % gold_amount)
	
	# Mostrar o que foi encontrado
	var reward_text = "Você encontrou: " + ", ".join(rewards)
	show_dialog(reward_text)
	
	# Marcar como usado
	has_been_used = true
	can_interact = false 