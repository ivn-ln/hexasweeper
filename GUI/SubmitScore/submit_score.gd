extends CenterContainer

signal score_submitted
var score_value = 999.0


func submit_new_score():
	await SilentWolf.Scores.save_score($PanelContainer/MarginContainer/VBoxContainer/LineEdit.text, score_value).sw_save_score_complete
	print('score_saved')
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
