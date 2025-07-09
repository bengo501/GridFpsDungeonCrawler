extends Control

signal dialog_finished

var current_dialog = null
var current_line = 0
var is_typing = false
var type_speed = 0.05

func _ready():
	# Esconder o HUD inicialmente
	hide()

func show_dialog(dialog_data: Dictionary):
	current_dialog = dialog_data
	current_line = 0
	
	var speaker_name = get_node_or_null("VBoxContainer/SpeakerName")
	var dialog_text = get_node_or_null("VBoxContainer/DialogText")
	
	if speaker_name:
		speaker_name.text = dialog_data.speaker
	
	if dialog_text:
		dialog_text.text = ""
		dialog_text.visible_characters = 0
	
	show()
	_start_typewriter_effect()

func _start_typewriter_effect():
	var dialog_text = get_node_or_null("VBoxContainer/DialogText")
	if not dialog_text or not current_dialog or not current_dialog.has("lines"):
		return
		
	if current_line >= current_dialog.lines.size():
		_finish_dialog()
		return
		
	dialog_text.text = current_dialog.lines[current_line]
	is_typing = true
	
	# Efeito de digitação
	for i in range(dialog_text.text.length() + 1):
		if not is_typing:
			break
		dialog_text.visible_characters = i
		await get_tree().create_timer(type_speed).timeout
	
	is_typing = false

func _skip_typewriter():
	var dialog_text = get_node_or_null("VBoxContainer/DialogText")
	if dialog_text:
		dialog_text.visible_characters = -1
		is_typing = false

func _next_line():
	if is_typing:
		_skip_typewriter()
	else:
		current_line += 1
		if current_line >= current_dialog.lines.size():
			_finish_dialog()
		else:
			_start_typewriter_effect()

func _finish_dialog():
	hide()
	dialog_finished.emit()
	current_dialog = null
	current_line = 0

func _unhandled_input(event):
	if not visible:
		return
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interacst"):
		_next_line()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_finish_dialog()
		get_viewport().set_input_as_handled() 
