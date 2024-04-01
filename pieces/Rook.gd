extends Piece


# Called when the node enters the scene tree for the first time.
func _ready():
	type = "R"
	moves_list = [[-1, 0, 3], [1, 0, 3], [0, -1, 2], [0, 1, 2]]
	max_hp = 5
	attack = 5
	super()
