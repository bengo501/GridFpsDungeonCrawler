extends Control

var selected_save_id = -1

func _ready():
	# Conectar sinais
	$VBoxContainer/SaveList.item_selected.connect(_on_save_selected)
	$VBoxContainer/HBoxContainer/LoadButton.pressed.connect(_on_load_pressed)
	$VBoxContainer/HBoxContainer/DeleteButton.pressed.connect(_on_delete_pressed)
	$VBoxContainer/HBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# Atualizar lista de saves
	_update_save_list()

func _update_save_list():
	$VBoxContainer/SaveList.clear()
	var saves = SaveManager.get_save_list()
	
	for save in saves:
		var save_info = "Save %d - %s" % [save.id, save.date]
		$VBoxContainer/SaveList.add_item(save_info)
		
		# Adicionar informações adicionais
		var item_idx = $VBoxContainer/SaveList.get_item_count() - 1
		$VBoxContainer/SaveList.set_item_tooltip(item_idx, "Nível: %d\nTempo: %s" % [save.level, save.play_time])

func _on_save_selected(index):
	selected_save_id = index

func _on_load_pressed():
	if selected_save_id >= 0:
		SaveManager.load_save(selected_save_id)
		GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)

func _on_delete_pressed():
	if selected_save_id >= 0:
		SaveManager.delete_save(selected_save_id)
		_update_save_list()
		selected_save_id = -1

func _on_back_pressed():
	GameStateManager.change_state(GameStateManager.previous_state) 