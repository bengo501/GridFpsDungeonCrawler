extends Node3D

# Referências
@onready var puzzle_area = $PuzzleArea
@onready var puzzle_hud = $UIContainer/PuzzleHUD

# Variáveis
var puzzle_data = {}
var puzzle_solved = false

func _ready():
	# Conectar sinais
	GameStateManager.game_state_changed.connect(_on_game_state_changed)
	
	# Carregar dados do puzzle
	load_puzzle_data()

func load_puzzle_data():
	# Carregar dados do puzzle atual
	puzzle_data = GameManager.current_puzzle_data
	
	# Configurar área do puzzle
	setup_puzzle_area()

func setup_puzzle_area():
	# Configurar elementos do puzzle baseado nos dados
	pass

func _on_game_state_changed(new_state: int):
	match new_state:
		GameStateManager.GameState.PUZZLE:
			# Mostrar HUD do puzzle
			puzzle_hud.show()
		GameStateManager.GameState.PAUSED:
			# Pausar puzzle
			puzzle_hud.hide()
		GameStateManager.GameState.EXPLORATION:
			# Voltar para exploração
			if puzzle_solved:
				# Dar recompensa
				give_puzzle_reward()
			SceneManager.change_scene("world")

func solve_puzzle():
	puzzle_solved = true
	GameManager.complete_puzzle()
	GameStateManager.change_state(GameStateManager.GameState.EXPLORATION)

func give_puzzle_reward():
	# Dar recompensas do puzzle
	var exp_gained = puzzle_data.get("experience", 0)
	var gold_gained = puzzle_data.get("gold", 0)
	var item_reward = puzzle_data.get("item_reward", null)
	
	GameManager.add_experience(exp_gained)
	GameManager.add_gold(gold_gained)
	
	if item_reward:
		GameManager.add_item(item_reward) 