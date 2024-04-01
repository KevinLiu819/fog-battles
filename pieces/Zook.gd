extends Piece


# Called when the node enters the scene tree for the first time.
func _ready():
	type = "Z"
	moves_list = [[-1, -1, 7], [-1, 0, 7], [-1, 1, 7], [0, -1, 7], [0, 1, 7], [1, -1, 7], \
		[1, 0, 7], [1, 1, 7]]
	max_hp = 1
	attack = 9999
	super()

# Special Zook function
func on_melee_attack():
	hp = 0
