extends Control


func _on_button_pressed():
	$AudioStreamPlayer.play()
	if $"MarginContainer/1".visible:
		$"MarginContainer/2/VBoxContainer/TextureRect".texture.current_frame = 0
		$"MarginContainer/1".hide()
		$"MarginContainer/2".show()
		return
	if $"MarginContainer/2".visible:
		$"MarginContainer/2".hide()
		$"MarginContainer/3".show()
		return
	if $"MarginContainer/3".visible:
		$"MarginContainer/4/VBoxContainer/TextureRect".texture.current_frame = 0
		$"MarginContainer/3".hide()
		$"MarginContainer/4".show()
		return
	if $"MarginContainer/4".visible:
		$"MarginContainer/5/VBoxContainer/TextureRect".texture.current_frame = 0
		$"MarginContainer/4".hide()
		$"MarginContainer/5".show()
		$Button.text ='Close'
		return
	if $"MarginContainer/5".visible:
		$"MarginContainer/5".hide()
		$"MarginContainer/1".show()
		$Button.text ='Next>'
		hide()
