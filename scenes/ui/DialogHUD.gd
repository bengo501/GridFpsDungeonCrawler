extends Control

signal dialog_finished

var current_dialog = []
var current_index = 0
var is_typing = false
var type_speed = 0.05
var type_timer = 0.0

func _ready():
	# Esconder o HUD inicialmente
	hide()

func _process(delta):
	if is_typing:
		type_timer += delta
		if type_timer >= type_speed:
			type_timer = 0.0
			_show_next_character()

func start_dialog(dialog_data: Array):
	current_dialog = dialog_data
	current_index = 0
	show()
	_show_current_dialog()

func _show_current_dialog():
	if current_index >= current_dialog.size():
		hide()
		dialog_finished.emit()
		return
	
	var dialog = current_dialog[current_index]
	$VBoxContainer/SpeakerName.text = dialog.speaker
	$VBoxContainer/DialogText.text = ""
	$VBoxContainer/DialogText.visible_characters = 0
	is_typing = true

func _show_next_character():
	var text = current_dialog[current_index].text
	var visible_chars = $VBoxContainer/DialogText.visible_characters
	
	if visible_chars < text.length():
		$VBoxContainer/DialogText.visible_characters += 1
	else:
		is_typing = false

func _unhandled_input(event):
	if not visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# Mostrar todo o texto imediatamente
			$VBoxContainer/DialogText.visible_characters = -1
			is_typing = false
		else:
			# Avançar para o próximo diálogo
			current_index += 1
			_show_current_dialog() 