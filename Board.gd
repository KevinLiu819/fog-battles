extends TileMap

var piece_scene : PackedScene = preload("res://Piece.tscn")
var zook_scene : PackedScene = preload("res://pieces/Zook.tscn")
var doomba_scene : PackedScene = preload("res://pieces/Doomba.tscn")
var lancer_scene : PackedScene = preload("res://pieces/Lancer.tscn")
var rook_scene : PackedScene = preload("res://pieces/Rook.tscn")
var pieces = Array()
var last_move = Array()

var white_to_move = true
var selected_square = null
var piece_selected = null

signal generate_move_label(move_text)
signal save_board_state()
signal display_promotion_screen(color, square)


func save() -> Dictionary:
	return {
		"white_to_move": white_to_move,
		"last_move": last_move,
		"pieces": save_pieces()
	}

func save_pieces() -> Array:
	var result = Array()
	for piece in pieces:
		result.append(piece.save())
	return result

func load_board(save_dict):
	# Clear board first
	for piece in pieces:
		piece.queue_free()
	pieces.clear()
	# Load board
	white_to_move = save_dict["white_to_move"]
	# Update last move
	last_move = save_dict["last_move"]
	# Load pieces
	for piece in save_dict["pieces"]:
		create_piece(piece["square"], piece["type"], piece["color"], piece["moves"])

# Called when the node enters the scene tree for the first time.
func _ready():
	# process_mode = Node.PROCESS_MODE_PAUSABLE
	create_piece(Vector2i(0, 0), "Z", true)
	create_piece(Vector2i(7, 0), "Z", false)
	create_piece(Vector2i(1, 1), "D", true)
	create_piece(Vector2i(6, 6), "D", false)
	create_piece(Vector2i(1, 2), "L", true)
	create_piece(Vector2i(5, 6), "L", false)
	create_piece(Vector2i(3, 2), "R", true)
	create_piece(Vector2i(7, 6), "R", false)


func create_piece(square, type, color, moves = 0, visibility = true):
	# var piece = piece_scene.instantiate()
	var piece
	if type == "Z":
		piece = zook_scene.instantiate()
	elif type == "D":
		piece = doomba_scene.instantiate()
		piece.connect("doomba_effect", _on_doomba_effect)
	elif type == "L":
		piece = lancer_scene.instantiate()
	elif type == "R":
		piece = rook_scene.instantiate()
	piece.square = square
	piece.color = color
	piece.moves = moves
	piece.visible = visibility
	if visibility:
		pieces.append(piece)
	add_child(piece)
	return piece

func valid_moves(piece) -> Array:
	var valid_moves = Array()
	for move in piece.moves_list:
		var count = 0
		var square = piece.square
		while count < move[2]:
			square += Vector2i(move[0], move[1])
			if out_of_bounds(square):
				break
			var next_piece = get_piece(square)
			if next_piece == null or next_piece.color != white_to_move:
				valid_moves.append(square)
			if next_piece != null:
				break
			count += 1
	return valid_moves


func _on_doomba_effect(piece):
	var square = piece.square
	for i in range(square.x - 1, square.x + 2):
		for j in range(square.y - 1, square.y + 2):
			var target_piece = get_piece(Vector2i(i, j))
			if target_piece != null and target_piece.color != piece.color:
				target_piece.hp -= 1


func make_move(piece, next_square):
	var next_piece = get_piece(next_square)
	piece.square = next_square
	if next_piece != null:
		# Melee attack
		next_piece.hp -= piece.attack
		if next_piece.hp > 0:
			piece.hp = 0
		piece.on_melee_attack()
	piece.after_move_attack()
	white_to_move = not white_to_move

func delete_piece(piece):
	pieces.erase(piece)
	piece.queue_free()

func undo_move(piece, prev_square, next_square_piece, flip_turn):
	piece.position = map_to_local(prev_square)
	piece.square = prev_square
	piece.moves -= 1
	if next_square_piece != null:
		next_square_piece.visible = true
		pieces.append(next_square_piece)
	if flip_turn:
		white_to_move = not white_to_move

func out_of_bounds(square) -> bool:
	return not get_used_cells(0).has(square)

func piece_exists(square) -> bool:
	return get_piece(square) != null

func get_piece(square) -> Sprite2D:
	for piece in pieces:
		if piece.square == square:
			return piece
	return null
