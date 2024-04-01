extends Piece


# Called when the node enters the scene tree for the first time.
func _ready():
	type = "L"
	moves_list = [[0, 1, 3], [-1, -1, 1], [0, -1, 1], [1, -1, 1]]
	max_hp = 3
	attack = 3
	super()
