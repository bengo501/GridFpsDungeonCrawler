extends Control

signal interaction_closed
signal option_selected(option_index: int)

var current_options = []

func _ready():
	# Conectar sinais dos botões
	$InteractionPanel/VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)
	
	# Esconder o HUD inicialmente
	hide()

func show_interaction(title: String, description: String, options: Array):
	$InteractionPanel/VBoxContainer/Title.text = title
	$InteractionPanel/VBoxContainer/Description.text = description
	
	# Limpar opções anteriores
	for child in $InteractionPanel/VBoxContainer/Options.get_children():
		child.queue_free()
	
	# Adicionar novas opções
	current_options = options
	for i in range(options.size()):
		var button = Button.new()
		button.text = options[i]
		button.pressed.connect(_on_option_pressed.bind(i))
		$InteractionPanel/VBoxContainer/Options.add_child(button)
	
	show()

func _on_option_pressed(option_index: int):
	option_selected.emit(option_index)
	hide()

func _on_close_pressed():
	interaction_closed.emit()
	hide()

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled() 