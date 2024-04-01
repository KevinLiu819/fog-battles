extends Sprite2D
class_name Piece

var type : String
var square : Vector2i
var color : bool
var hp : int
var max_hp : int
var attack : int
var moves_list : Array
var valid_moves : Array

var moves = 0
var follow_mouse = false

func save() -> Dictionary:
	return {
		"square": square,
		"type": type,
		"color": color,
		"moves": moves,
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	position = get_parent().map_to_local(square)
	hp = max_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("click") and follow_mouse:
		position = get_global_mouse_position()
	if hp <= 0:
		on_death()

func _input(event):
	var mouse_pos = get_global_mouse_position()
	var mouse_square = get_parent().local_to_map(mouse_pos)
	if event.is_action_pressed("click") \
			and mouse_square == square and get_parent().white_to_move == color:
		handle_select_piece(mouse_square)
	elif event.is_action_released("click") and follow_mouse:
		handle_release_piece(mouse_square)

func handle_select_piece(mouse_square):
	print(mouse_square)
	follow_mouse = true
	valid_moves = get_parent().valid_moves(self)
	z_index = 1
	print(valid_moves)

func handle_release_piece(mouse_square):
	print(mouse_square)
	follow_mouse = false
	z_index = 0
	if valid_moves.has(mouse_square):
		get_parent().make_move(self, mouse_square)
	position = get_parent().map_to_local(square)


func on_melee_attack():
	pass

func after_move_attack():
	pass

func on_death():
	get_parent().delete_piece(self)
