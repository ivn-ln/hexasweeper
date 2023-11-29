extends CenterContainer

signal score_submitted
var score_value = 9999


func _ready():
	var table = Globals.current_difficulty
	if table == 'Easy':
		table = 'main'
	if table == 'Medium':
		table = 'medium'
	if table == 'Hard':
		table = 'hard'
	table = table.to_lower()
	if Globals.player_id == '':
		return
	var player_data = await SilentWolf.Scores.get_top_score_by_player(Globals.player_id, 0, table).sw_top_player_score_complete
	if player_data['top_score']!= {}:
		$PanelContainer/MarginContainer/VBoxContainer/LineEdit.text = player_data['top_score']['metadata']['display_name']
		$PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Submit.disabled = false

func submit_new_score():
	var metadata = {
		'display_name' = $PanelContainer/MarginContainer/VBoxContainer/LineEdit.text
	}
	var table = Globals.current_difficulty
	if table == 'Easy':
		table = 'main'
	if table == 'Medium':
		table = 'medium'
	if table == 'Hard':
		table = 'hard'
	var player_id = $PanelContainer/MarginContainer/VBoxContainer/LineEdit.text
	var res = floorf((1 / score_value) * 100000 * 1000)/1000
	await SilentWolf.Scores.save_score(player_id, floorf((1 / score_value) * 100000 * 1000)/1000, table, metadata).sw_save_score_complete
	score_submitted.emit()
	hide()
	$PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Submit.disabled = false
	$PanelContainer/MarginContainer/VBoxContainer/LineEdit.editable = true


func _on_submit_pressed():
	submit_new_score()
	$PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Submit.disabled = true
	$PanelContainer/MarginContainer/VBoxContainer/LineEdit.editable = false


func _on_line_edit_text_changed(new_text):
	$PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Submit.disabled = not new_text.length() > 0


func _on_cancel_pressed():
	hide()
