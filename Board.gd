extends TileMap

const COMPUTER_DELAY = 0.25
const VISION_DIR = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 0], [0, 1], [1, -1], [1, 0], [1, 1]]

var piece_scene : PackedScene = preload("res://Piece.tscn")
var zook_scene : PackedScene = preload("res://pieces/Zook.tscn")
var doomba_scene : PackedScene = preload("res://pieces/Doomba.tscn")
var lancer_scene : PackedScene = preload("res://pieces/Lancer.tscn")
var rook_scene : PackedScene = preload("res://pieces/Rook.tscn")

var pieces = Array()
var last_move = Array()
var player_move = true

var rng = RandomNumberGenerator.new()

signal save_board_state()


func save() -> Dictionary:
	return {
		"player_move": player_move,
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
	player_move = save_dict["player_move"]
	# Update last move
	last_move = save_dict["last_move"]
	# Load pieces
	for piece in save_dict["pieces"]:
		create_piece(piece["square"], piece["type"], piece["color"], piece["moves"])

# Called when the node enters the scene tree for the first time.
func _ready():
	# process_mode = Node.PROCESS_MODE_PAUSABLE
	create_piece(Vector2i(0, 7), "D", true)
	create_piece(Vector2i(1, 7), "D", true)
	create_piece(Vector2i(2, 7), "D", true)
	create_piece(Vector2i(3, 7), "D", true)
	for i in range(8):
		create_piece(Vector2i(i, 0), "L", false)
		create_piece(Vector2i(i, 1), "R", false)
	# create_piece(Vector2i(6, 6), "D", false)
	# create_piece(Vector2i(7, 6), "R", false)
	update_vision()


func create_piece(square, type, color, moves = 0, visibility = true):
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

func delete_piece(piece):
	pieces.erase(piece)
	piece.queue_free()


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
			if next_piece == null or next_piece.color != player_move:
				valid_moves.append(square)
			if next_piece != null:
				break
			count += 1
	return valid_moves

func make_move(piece, next_square):
	var next_piece = get_piece(next_square)
	piece.square = next_square
	if next_piece != null:
		# Melee attack
		next_piece.hp -= piece.attack
		if next_piece.hp > 0:
			piece.hp = 0
		await piece.on_melee_attack()
	# Post-move specials
	await piece.after_move_attack()
	player_move = not player_move
	# TODO: update vision
	update_vision()
	if not player_move:
		await get_tree().create_timer(COMPUTER_DELAY).timeout
		computer_move()

func computer_move():
	var computer_pieces = []
	for piece in pieces:
		if not piece.color and not valid_moves(piece).is_empty():
			computer_pieces.append(piece)
	if computer_pieces.is_empty():
		print("You win!")
		return
	var random_piece_index = rng.randi_range(0, computer_pieces.size() - 1)
	var chosen_piece = computer_pieces[random_piece_index]
	var chosen_piece_moves = valid_moves(chosen_piece)
	var random_move_index = rng.randi_range(0, chosen_piece_moves.size() - 1)
	var chosen_square = chosen_piece_moves[random_move_index]
	make_move(chosen_piece, chosen_square)

func undo_move(piece, prev_square, next_square_piece, flip_turn):
	piece.position = map_to_local(prev_square)
	piece.square = prev_square
	piece.moves -= 1
	if next_square_piece != null:
		next_square_piece.visible = true
		pieces.append(next_square_piece)
	if flip_turn:
		player_move = not player_move


func update_vision():
	clear_layer(1)
	var vision_squares = Dictionary()
	for piece in pieces:
		if piece.color:
			for dir in VISION_DIR:
				var next_square = piece.square + Vector2i(dir[0], dir[1])
				if not out_of_bounds(next_square):
					vision_squares[next_square] = true
	for square in get_used_cells(0):
		if not vision_squares.has(square):
			set_cell(1, square, 1, Vector2i(0, 0))

"""
Random effects
"""

func _on_doomba_effect(piece):
	var square = piece.square
	for i in range(square.x - 1, square.x + 2):
		for j in range(square.y - 1, square.y + 2):
			var target_piece = get_piece(Vector2i(i, j))
			if target_piece != null and target_piece.color != piece.color:
				target_piece.hp -= 1


func out_of_bounds(square) -> bool:
	return not get_used_cells(0).has(square)

func piece_exists(square) -> bool:
	return get_piece(square) != null

func get_piece(square) -> Sprite2D:
	for piece in pieces:
		if piece.square == square:
			return piece
	return null
