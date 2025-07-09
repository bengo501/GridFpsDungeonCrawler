extends Area3D
class_name Interactable

signal interaction_started(interactable: Interactable)
signal interaction_ended(interactable: Interactable)

@export var interaction_text: String = "Pressione F para interagir"
@export var interaction_title: String = "Objeto"
@export var interaction_description: String = "Um objeto misterioso"
@export var interaction_options: Array[String] = ["Examinar", "Usar"]
@export var can_interact: bool = true
@export var one_time_use: bool = false

var is_player_nearby: bool = false
var has_been_used: bool = false

func _ready():
	# Conectar sinais
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Configurar collision layer
	collision_layer = 2  # Interactable layer
	collision_mask = 1   # Player layer

func _on_body_entered(body):
	if body.has_method("is_player") and body.is_player():
		is_player_nearby = true
		if can_interact and not (one_time_use and has_been_used):
			_show_interaction_prompt()

func _on_body_exited(body):
	if body.has_method("is_player") and body.is_player():
		is_player_nearby = false
		_hide_interaction_prompt()

func _show_interaction_prompt():
	var exploration_hud = UIManager.get_ui_instance(UIManager.UIScreen.EXPLORATION_HUD)
	if exploration_hud:
		exploration_hud.show_interaction_prompt(true)

func _hide_interaction_prompt():
	var exploration_hud = UIManager.get_ui_instance(UIManager.UIScreen.EXPLORATION_HUD)
	if exploration_hud:
		exploration_hud.show_interaction_prompt(false)

func interact():
	if not can_interact or (one_time_use and has_been_used):
		return
	
	interaction_started.emit(self)
	
	# Mostrar menu de interação
	var interaction_hud = UIManager.get_ui_instance(UIManager.UIScreen.INTERACTION_HUD)
	if interaction_hud:
		interaction_hud.show_interaction(interaction_title, interaction_description, interaction_options)
		interaction_hud.option_selected.connect(_on_option_selected)
		interaction_hud.interaction_closed.connect(_on_interaction_closed)

func _on_option_selected(option_index: int):
	if option_index >= 0 and option_index < interaction_options.size():
		var option = interaction_options[option_index]
		handle_interaction_option(option)
	
	if one_time_use:
		has_been_used = true
		can_interact = false
	
	interaction_ended.emit(self)

func _on_interaction_closed():
	interaction_ended.emit(self)

func handle_interaction_option(option: String):
	# Implementar em subclasses
	match option:
		"Examinar":
			show_dialog("Você examina o objeto cuidadosamente.")
		"Usar":
			show_dialog("Você usa o objeto.")
		_:
			show_dialog("Ação não implementada.")

func show_dialog(text: String):
	var dialog_data = {
		"speaker": "Narrador",
		"lines": [text]
	}
	
	var dialog_hud = UIManager.get_ui_instance(UIManager.UIScreen.DIALOG_HUD)
	if dialog_hud:
		dialog_hud.show_dialog(dialog_data) 