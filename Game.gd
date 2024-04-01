extends Node2D

var board_scene : PackedScene = preload("res://Board.tscn")
var board
var board_states = Array()


# Called when the node enters the scene tree for the first time.
func _ready():
	board = board_scene.instantiate()
	board.connect("save_board_state", _on_save_board_state)
	add_child(board)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_save_board_state():
	board_states.append(board.save())

func _on_load_board_state(index, paused):
	await board.load_board(board_states[index])

