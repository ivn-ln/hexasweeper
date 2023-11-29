extends Control


func _ready():
	#$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/AudioButton.button_pressed
	$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/AudioButton.button_pressed = Globals.enable_audio
	$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VibrationButton.button_pressed = Globals.enable_vibration
	$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/DiscoColorsButton.button_pressed = Globals.random_colors
	$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/AnimationsButton.button_pressed = Globals.enable_animations
	$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ShowTimerButton.button_pressed = Globals.show_timer
	$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ShowMinesButton.button_pressed = Globals.show_mines
	$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/DarkThemeButton.button_pressed = Globals.dark_mode
	if OS.get_name() != 'Android' and OS.get_name() != 'Web':
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/Spacer3.hide()
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VibrationButton.hide()

func _process(delta):
	if not Globals.enable_audio:
			$AudioStreamPlayer.volume_db = -90
	else:
		$AudioStreamPlayer.volume_db = -20
	$Panel.self_modulate = RenderingServer.get_default_clear_color()
	if not Globals.dark_mode:
		$VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Back.self_modulate = Color.BLACK
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/AudioButton.self_modulate = Color.BLACK
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VibrationButton.self_modulate = Color.BLACK
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/DiscoColorsButton.self_modulate = Color.BLACK
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/AnimationsButton.self_modulate = Color.BLACK
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ShowTimerButton.self_modulate = Color.BLACK
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ShowMinesButton.self_modulate = Color.BLACK
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/DarkThemeButton.self_modulate = Color.BLACK
	else:
		$VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Back.self_modulate = Color.WHITE
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/AudioButton.self_modulate = Color.WHITE
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VibrationButton.self_modulate = Color.WHITE
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/DiscoColorsButton.self_modulate = Color.WHITE
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/AnimationsButton.self_modulate = Color.WHITE
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ShowTimerButton.self_modulate = Color.WHITE
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ShowMinesButton.self_modulate = Color.WHITE
		$VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/DarkThemeButton.self_modulate = Color.WHITE


func _on_back_pressed():
	#$VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Back.disabled = true
	$AudioStreamPlayer.play()
	await create_tween().tween_property(self,'global_position' , Vector2(720,0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).finished
	get_tree().paused = false



func _on_dark_theme_button_toggled(button_pressed):
	if button_pressed:
		$AudioStreamPlayer.pitch_scale = 1.3
	else:
		$AudioStreamPlayer.pitch_scale = 0.7
	$AudioStreamPlayer.play()
	Globals.dark_mode = button_pressed


func _on_show_mines_button_toggled(button_pressed):
	if button_pressed:
		$AudioStreamPlayer.pitch_scale = 1.3
	else:
		$AudioStreamPlayer.pitch_scale = 0.7
	$AudioStreamPlayer.play()
	Globals.show_mines = button_pressed


func _on_show_timer_button_toggled(button_pressed):
	if button_pressed:
		$AudioStreamPlayer.pitch_scale = 1.3
	else:
		$AudioStreamPlayer.pitch_scale = 0.7
	$AudioStreamPlayer.play()
	Globals.show_timer = button_pressed


func _on_animations_button_toggled(button_pressed):
	if button_pressed:
		$AudioStreamPlayer.pitch_scale = 1.3
	else:
		$AudioStreamPlayer.pitch_scale = 0.7
	$AudioStreamPlayer.play()
	Globals.enable_animations = button_pressed


func _on_disco_colors_button_toggled(button_pressed):
	if button_pressed:
		$AudioStreamPlayer.pitch_scale = 1.3
	else:
		$AudioStreamPlayer.pitch_scale = 0.7
	$AudioStreamPlayer.play()
	Globals.random_colors = button_pressed


func _on_vibration_button_toggled(button_pressed):
	if button_pressed:
		$AudioStreamPlayer.pitch_scale = 1.3
	else:
		$AudioStreamPlayer.pitch_scale = 0.7
	$AudioStreamPlayer.play()
	Globals.enable_vibration = button_pressed


func _on_audio_button_toggled(button_pressed):
	if button_pressed:
		$AudioStreamPlayer.pitch_scale = 1.3
	else:
		$AudioStreamPlayer.pitch_scale = 0.7
	$AudioStreamPlayer.play()
	Globals.enable_audio = button_pressed


func _on_menu_pressed():
	_on_back_pressed()
	$AudioStreamPlayer.play()
	get_parent().get_parent().get_parent().transition_to_menu()


func _on_leaders_pressed():
	$Leaders.show()
	$Leaders.update_scores()
