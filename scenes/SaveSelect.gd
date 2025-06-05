extends Node

# Referências
@onready var save_select_ui = $UIContainer/SaveSelect

func _ready():
	# Conectar sinais
	save_select_ui.back_pressed.connect(_on_back_pressed)
	save_select_ui.save_selected.connect(_on_save_selected)
	save_select_ui.save_deleted.connect(_on_save_deleted)
	save_select_ui.new_save_pressed.connect(_on_new_save_pressed)
	
	# Carregar lista de saves
	load_save_list()

func load_save_list():
	# Obter lista de saves
	var saves = SaveManager.get_save_list()
	
	# Atualizar UI
	save_select_ui.update_save_list(saves)

func _on_back_pressed():
	# Voltar para cena anterior
	GameStateManager.change_state(GameStateManager.previous_state)

func _on_save_selected(save_id: String):
	# Carregar save selecionado
	SaveManager.load_save(save_id)
	
	# Iniciar jogo
	GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)

func _on_save_deleted(save_id: String):
	# Deletar save
	SaveManager.delete_save(save_id)
	
	# Atualizar lista
	load_save_list()

func _on_new_save_pressed():
	# Criar novo save
	SaveManager.create_save()
	
	# Iniciar jogo
	GameStateManager.change_state(GameStateManager.GameState.EXPLORATION) 