extends Control


var difficulty_id = 0
var moon = preload("res://Sprites/moon.png")
var sun = preload("res://Sprites/sun.png")


func _ready():
	get_tree().paused = false
	$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.text = Globals.current_difficulty
	difficulty_id = Globals.difficulty.find(Globals.current_difficulty)
	if difficulty_id == 0:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffDec.disabled = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffDec.disabled = false
	if difficulty_id == Globals.difficulty.size()-1:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffInc.disabled = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffInc.disabled = false


func _process(delta):
	$Panel.self_modulate = RenderingServer.get_default_clear_color()
	if Globals.dark_mode:
		$MarginContainer/VBoxContainer/Label.self_modulate = Color.WHITE
	else:
		$MarginContainer/VBoxContainer/Label.self_modulate = Color.BLACK



func _on_play_pressed():
	$MarginContainer/VBoxContainer/CenterContainer/Play.disabled = true
	$AudioStreamPlayer4.play()
	get_parent().get_parent().transition_to_game()


func _on_how_to_button_pressed():
	$HowTo.show()
	$AudioStreamPlayer.play()


func _on_diff_inc_pressed():
	$AudioStreamPlayer.play()
	difficulty_id = min(Globals.difficulty.size()-1, difficulty_id + 1)
	if difficulty_id == 0:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffDec.disabled = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffDec.disabled = false
	match difficulty_id:
		0:
			$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.self_modulate = Color.from_string('00cf7f', Color.BLACK)
		1:
			$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.self_modulate = Color.from_string('ffcf7f', Color.BLACK)
		2:
			$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.self_modulate = Color.from_string('ff8082', Color.BLACK)
	if difficulty_id == Globals.difficulty.size()-1:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffInc.disabled = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffInc.disabled = false
	Globals.current_difficulty = Globals.difficulty[difficulty_id]
	$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.text = Globals.current_difficulty


func _on_diff_dec_pressed():
	$AudioStreamPlayer.play()
	difficulty_id = max(0, difficulty_id - 1)
	match difficulty_id:
		0:
			$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.self_modulate = Color.from_string('00cf7f', Color.BLACK)
		1:
			$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.self_modulate = Color.from_string('ffcf7f', Color.BLACK)
		2:
			$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.self_modulate = Color.from_string('ff8082', Color.BLACK)
	if difficulty_id == 0:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffDec.disabled = true
		
	else:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffDec.disabled = false
		
	if difficulty_id == Globals.difficulty.size()-1:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffInc.disabled = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffInc.disabled = false
	Globals.current_difficulty = Globals.difficulty[difficulty_id]
	$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.text = Globals.current_difficulty


func enable_play_button():
	$MarginContainer/VBoxContainer/CenterContainer/Play.disabled = false


func _on_leaderboards_pressed():
	$AudioStreamPlayer.play()
	$Leaders.show()
	$Leaders.update_scores()


func _on_label_pressed():
	Globals.dark_mode = not Globals.dark_mode
	if Globals.dark_mode:
		$Label.icon = moon
	else:
		$Label.icon = sun
