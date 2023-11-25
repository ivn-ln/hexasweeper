extends Control


var difficulty_id = 0


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


func _on_play_pressed():
	$MarginContainer/VBoxContainer/CenterContainer/Play.disabled = true
	$AudioStreamPlayer4.play()
	get_parent().get_parent().transition_to_game()


func _on_hide_pressed():
	$HowTo.hide()
	$AudioStreamPlayer.play()


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
	if difficulty_id == Globals.difficulty.size()-1:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffInc.disabled = true
	else:
		$MarginContainer/VBoxContainer/HBoxContainer/DiffInc.disabled = false
	Globals.current_difficulty = Globals.difficulty[difficulty_id]
	$MarginContainer/VBoxContainer/HBoxContainer/Difficulty.text = Globals.current_difficulty


func _on_diff_dec_pressed():
	$AudioStreamPlayer.play()
	difficulty_id = max(0, difficulty_id - 1)
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
	$Leaders.show()
	$Leaders.update_scores()
