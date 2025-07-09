extends Control

signal interaction_closed
signal option_selected(option_index: int)

var current_options = []

func _ready():
	# Aguarda um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Conectar sinais com verificações de segurança
	var close_button = get_node_or_null("InteractionPanel/VBoxContainer/CloseButton")
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	# Esconder o HUD inicialmente
	hide()

func show_interaction(title: String, description: String, options: Array):
	var title_label = get_node_or_null("InteractionPanel/VBoxContainer/Title")
	var description_label = get_node_or_null("InteractionPanel/VBoxContainer/Description")
	var options_container = get_node_or_null("InteractionPanel/VBoxContainer/Options")
	
	if title_label:
		title_label.text = title
	
	if description_label:
		description_label.text = description
	
	if options_container:
		# Limpar opções anteriores
		for child in options_container.get_children():
			child.queue_free()
		
		# Adicionar novas opções
		current_options = options
		for i in range(options.size()):
			var button = Button.new()
			button.text = options[i]
			button.pressed.connect(_on_option_pressed.bind(i))
			options_container.add_child(button)
	
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