extends Control

var selected_save_id = -1

func _ready():
	# Aguarda um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	
	# Conectar sinais com verificações de segurança
	var save_list = get_node_or_null("VBoxContainer/SaveList")
	var load_button = get_node_or_null("VBoxContainer/HBoxContainer/LoadButton")
	var delete_button = get_node_or_null("VBoxContainer/HBoxContainer/DeleteButton")
	var new_save_button = get_node_or_null("VBoxContainer/HBoxContainer/NewSaveButton")
	var back_button = get_node_or_null("VBoxContainer/HBoxContainer/BackButton")
	
	if save_list:
		save_list.item_selected.connect(_on_save_selected)
	
	if load_button:
		load_button.pressed.connect(_on_load_pressed)
	
	if delete_button:
		delete_button.pressed.connect(_on_delete_pressed)
	
	if new_save_button:
		new_save_button.pressed.connect(_on_new_save_pressed)
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	# Atualizar lista de saves
	update_save_list()

func update_save_list():
	var save_list = get_node_or_null("VBoxContainer/SaveList")
	if not save_list:
		return
		
	save_list.clear()
	selected_save_id = -1
	
	var saves = SaveManager.get_save_list()
	for save in saves:
		var save_info = "%s - %s" % [save.save_name, save.date_created]
		save_list.add_item(save_info)
		
		# Adicionar tooltip com informações detalhadas
		var item_idx = save_list.get_item_count() - 1
		save_list.set_item_tooltip(item_idx, "Nível: %d\nTempo: %s" % [save.level, save.play_time])

func _on_save_selected(index):
	selected_save_id = index

func _on_load_pressed():
	if selected_save_id >= 0:
		if SaveManager.load_save(selected_save_id):
			SceneManager.change_scene("world")
		else:
			print("Erro ao carregar save")

func _on_delete_pressed():
	if selected_save_id >= 0:
		SaveManager.delete_save(selected_save_id)
		update_save_list()

func _on_new_save_pressed():
	_show_save_name_dialog()

func _show_save_name_dialog():
	# Criar diálogo para nome do save
	var dialog = AcceptDialog.new()
	dialog.title = "Criar Novo Save"
	dialog.size = Vector2(300, 150)
	
	var vbox = VBoxContainer.new()
	dialog.add_child(vbox)
	
	var label = Label.new()
	label.text = "Nome do Save:"
	vbox.add_child(label)
	
	var line_edit = LineEdit.new()
	line_edit.text = "Novo Save"
	line_edit.placeholder_text = "Digite o nome do save"
	vbox.add_child(line_edit)
	
	# Adicionar botões
	var button_container = HBoxContainer.new()
	vbox.add_child(button_container)
	
	var create_button = Button.new()
	create_button.text = "Criar"
	create_button.pressed.connect(_on_create_save.bind(line_edit, dialog))
	button_container.add_child(create_button)
	
	var cancel_button = Button.new()
	cancel_button.text = "Cancelar"
	cancel_button.pressed.connect(dialog.queue_free)
	button_container.add_child(cancel_button)
	
	add_child(dialog)
	dialog.popup_centered()
	line_edit.grab_focus()
	line_edit.select_all()

func _on_create_save(line_edit: LineEdit, dialog: AcceptDialog):
	var save_name = line_edit.text.strip_edges()
	if save_name == "":
		save_name = "Novo Save"
	
	if SaveManager.create_save(save_name):
		update_save_list()
		print("Save criado com sucesso!")
	else:
		print("Erro ao criar save")
	
	dialog.queue_free()

func _on_back_pressed():
	GameStateManager.change_state(GameStateManager.previous_state) 