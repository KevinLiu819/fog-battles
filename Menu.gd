extends Control

const LABEL_SETTINGS : LabelSettings = preload("res://assets/pieces/Menu.tres")

var active : int = -1
var count : int = 0

signal load_board_state(index, paused)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_generate_move_label(move_text):
	if %MovesContainer.get_child_count() % 3 == 0:
		create_label(str(%MovesContainer.get_child_count() / 3 + 1))
		active += 1
		count += 1
	create_button(move_text)
	active += 1
	count += 1

func create_label(text):
	var label = Label.new()
	label.label_settings = LABEL_SETTINGS
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	%MovesContainer.add_child(label)

func create_button(text):
	var button = Button.new()
	button.add_theme_font_size_override("font_size", 36)
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_on_button_pressed.bind(count))
	button.disabled = true
	%MovesContainer.add_child(button)
	# Undisable previous move
	var prev_idx = count - 1
	if prev_idx % 3 == 0:
		prev_idx -= 1
	if prev_idx > 0:
		var prev_button = %MovesContainer.get_child(prev_idx)
		prev_button.disabled = false

func _on_button_pressed(index):
	var curr_button = %MovesContainer.get_child(active)
	curr_button.disabled = false
	var next_button = %MovesContainer.get_child(index)
	next_button.disabled = true
	active = index
	var board_index = (index / 3) * 2 + (index % 3 - 1)
	var paused = index != count
	load_board_state.emit(board_index, paused)
	
