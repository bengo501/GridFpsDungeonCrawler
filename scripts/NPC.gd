extends Interactable
class_name NPC

@export var npc_name: String = "Aldeão"
@export var greeting_dialog: Array[String] = ["Olá, viajante!"]
@export var shop_items: Array[String] = []
@export var is_merchant: bool = false
@export var has_quest: bool = false
@export var quest_id: String = ""

func _ready():
	super._ready()
	interaction_title = npc_name
	interaction_description = "Um " + npc_name.to_lower() + " local."
	
	# Configurar opções baseadas no tipo de NPC
	var options = ["Conversar"]
	if is_merchant:
		options.append("Comprar")
	if has_quest:
		options.append("Missão")
	
	interaction_options = options
	one_time_use = false

func handle_interaction_option(option: String):
	match option:
		"Conversar":
			start_conversation()
		"Comprar":
			if is_merchant:
				open_shop()
			else:
				show_dialog("Eu não tenho nada para vender.")
		"Missão":
			if has_quest:
				give_quest()
			else:
				show_dialog("Não tenho nenhuma missão para você agora.")

func start_conversation():
	var dialog_data = {
		"speaker": npc_name,
		"lines": greeting_dialog
	}
	
	var dialog_hud = UIManager.get_ui_instance(UIManager.UIScreen.DIALOG_HUD)
	if dialog_hud:
		dialog_hud.show_dialog(dialog_data)

func open_shop():
	if not is_merchant or shop_items.is_empty():
		show_dialog("Desculpe, não tenho nada para vender no momento.")
		return
	
	# Criar menu de loja simples
	var shop_text = "Itens disponíveis:\n"
	for item_id in shop_items:
		var item_data = GameManager.item_database.get(item_id, {})
		var item_name = item_data.get("name", item_id)
		var price = item_data.get("price", 10)
		shop_text += "- %s: %d ouro\n" % [item_name, price]
	
	show_dialog(shop_text + "\n(Sistema de compra será implementado em breve)")

func give_quest():
	if not has_quest:
		return
	
	# Sistema de missões simples
	match quest_id:
		"kill_goblins":
			show_dialog("Preciso que você derrote 3 goblins na floresta. Eles estão causando problemas para os viajantes.")
		"find_artifact":
			show_dialog("Há um artefato antigo perdido nas ruínas ao norte. Você pode encontrá-lo para mim?")
		_:
			show_dialog("Tenho uma missão para você, mas ainda não está pronta.") 