extends Piece

var melee_attack_death = false

signal doomba_effect(piece)

# Called when the node enters the scene tree for the first time.
func _ready():
	type = "D"
	moves_list = [[-1, -1, 2], [-1, 0, 2], [-1, 1, 2], [0, -1, 2], [0, 1, 2], [1, -1, 2], \
		[1, 0, 2], [1, 1, 2]]
	max_hp = 1
	attack = 0
	super()

func on_melee_attack():
	melee_attack_death = true
	on_death()

# Special Doomba function
func after_move_attack():
	if not melee_attack_death:
		doomba_effect.emit(self)
