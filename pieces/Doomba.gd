extends Piece

signal doomba_effect(piece)

# Called when the node enters the scene tree for the first time.
func _ready():
	type = "D"
	moves_list = [[-1, -1, 2], [-1, 0, 2], [-1, 1, 2], [0, -1, 2], [0, 1, 2], [1, -1, 2], \
		[1, 0, 2], [1, 1, 2]]
	max_hp = 1
	attack = 0
	super()


# Special Doomba function
func after_move_attack():
	doomba_effect.emit(self)
