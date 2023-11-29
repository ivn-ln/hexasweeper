extends TextureButton


signal cell_pressed(cell)
signal cell_flagged(flag_status)
var treasures_amount = 0
var is_treasure_values_revealed = false
var is_revealed = false
var is_flagged = false
var base_scale = Vector2(1.0, 1.0)
var ignore_click = false
@onready var hexagon = $MainPivot/Pivot
@onready var mine_label = $MainPivot/CenterContainer/MineLabel
var tile_color:
	set(value):
		tile_color = value
		if tile_color == null:
			return
		tile_color_revealed = Color.from_hsv(tile_color.h, tile_color.s - 0.5, tile_color.v + 0.2)
		if Globals.dark_mode:
			tile_color = Color.from_hsv(tile_color.h, tile_color.s - 0.5, tile_color.v - 0.1)
			tile_color_revealed = Color.from_hsv(tile_color.h, tile_color.s, tile_color.v - 0.2)
			$MainPivot/CenterContainer/MineLabel.add_theme_color_override("font_color", Color.WHITE)
			$MainPivot/CenterContainer/MineLabel.add_theme_color_override("font_outline_color", Color.WHITE)
		else:
			$MainPivot/CenterContainer/MineLabel.add_theme_color_override("font_color", Color.from_string('454545', Color.WHITE))
			$MainPivot/CenterContainer/MineLabel.add_theme_color_override("font_outline_color", Color.from_string('454545', Color.WHITE))
		$MainPivot/Pivot/HexagonTexture.self_modulate = tile_color
		$MainPivot/HexagonTextureRevealed.self_modulate = tile_color_revealed
@export var tile_color_revealed = Color.WHITE
@export var tween_duration = 0.5
var has_mana = false




var is_treasure = false


func _ready():
	if not Globals.DEBUG: return
	show_treasures_value()


func _process(delta):
	if not Globals.enable_audio:
		$AudioStreamPlayer.volume_db = -90
		$AudioStreamPlayer2.volume_db = -90
		$AudioStreamPlayer4.volume_db = -90
	else:
		$AudioStreamPlayer.volume_db = -20
		$AudioStreamPlayer.volume_db = -20
		$AudioStreamPlayer2.volume_db = -20
		$AudioStreamPlayer4.volume_db = -20
	$GPUParticles2D.process_material.scale_max = scale.x * 6 * 1.5
	$GPUParticles2D.process_material.scale_min = scale.x * 2 * 1.5


func set_treasures_value(value):
	treasures_amount = int(value)
	mine_label.text = str(value)


func show_treasures_value():
	if not is_treasure:
		$AudioStreamPlayer.pitch_scale = randf_range(1.2, 1.5)
		$AudioStreamPlayer.play()
	$MainPivot/PivotFlag/Flag.hide()
	disabled = true
	reveal()
	$MainPivot/Mana.visible = has_mana
	is_treasure_values_revealed = true
	if Globals.enable_animations:
		create_tween().tween_property($MainPivot/Pivot, 'modulate', Color.TRANSPARENT, tween_duration).set_ease(Tween.EASE_IN)
		create_tween().tween_property($MainPivot/Pivot, 'scale', Vector2(0,0), tween_duration).set_ease(Tween.EASE_IN)
		create_tween().tween_property($MainPivot/Pivot, 'rotation_degrees', 360, tween_duration).set_ease(Tween.EASE_IN)
	else:
		$MainPivot/Pivot.modulate = Color.TRANSPARENT
	if treasures_amount == 0:
		mine_label.text = ''


func reset():
	if Globals.enable_animations:
		create_tween().tween_property($MainPivot/Pivot, 'modulate', Color.WHITE, tween_duration).set_ease(Tween.EASE_OUT)
		create_tween().tween_property($MainPivot/Pivot, 'scale', Vector2(1,1), tween_duration).set_ease(Tween.EASE_OUT)
		create_tween().tween_property($MainPivot/Pivot, 'rotation_degrees', 0, tween_duration).set_ease(Tween.EASE_OUT)
		create_tween().tween_property($MainPivot/PivotMine, 'scale', Vector2(0, 0), tween_duration).set_ease(Tween.EASE_IN)
		create_tween().tween_property($MainPivot/PivotFlag, 'scale', Vector2(0, 0), tween_duration).set_ease(Tween.EASE_IN)
	else:
		$MainPivot/Pivot.modulate = Color.WHITE
		$MainPivot/Pivot.scale = Vector2(1,1)
		$MainPivot/Pivot.rotation_degrees = 0
		$MainPivot/PivotMine.scale = Vector2(0, 0)
		$MainPivot/PivotFlag.scale = Vector2(0, 0)
	$MainPivot/PivotFlag/Flag.show()
	is_treasure = false
	has_mana = false
	$MainPivot/Mana.hide()
	treasures_amount = 0
	is_treasure_values_revealed = false
	is_revealed = false
	is_flagged = false
	roll()

func reveal():
	is_revealed = true
	if is_treasure:
		if Globals.enable_vibration:
			Input.vibrate_handheld()
		if Globals.enable_animations:
			create_tween().tween_property($MainPivot/PivotMine, 'scale', Vector2(1.5, 1.5), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			create_tween().tween_property($MainPivot, 'rotation_degrees', $MainPivot.rotation_degrees + 360, tween_duration).set_ease(Tween.EASE_OUT)
			$AudioStreamPlayer4.pitch_scale = randf_range(0.4, 0.7)
			$AudioStreamPlayer4.play(0.05)
			$GPUParticles2D.emitting = true
			await get_tree().create_timer(0.5).timeout
			create_tween().tween_property($MainPivot/PivotMine, 'scale', Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		else:
			$MainPivot/PivotMine.scale = Vector2(1, 1)


func roll():
	if not Globals.enable_animations:
		return
	var scale_tween = create_tween()
	scale_tween.tween_property($MainPivot, 'scale', Vector2(1.0, 1.0) * 1.5, tween_duration/2).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property($MainPivot, 'scale', Vector2(1.0, 1.0), tween_duration/2).set_ease(Tween.EASE_IN)
	await create_tween().tween_property($MainPivot, 'rotation_degrees', $MainPivot.rotation_degrees + 360, tween_duration).set_ease(Tween.EASE_OUT).finished
	$MainPivot.rotation_degrees = 0

func _on_pressed():
	if ignore_click:
		ignore_click = false
		return
	if Input.is_action_just_released("Flag"):
		switch_flag()
		return
	if is_flagged:
		return
	cell_pressed.emit(self)
	show_treasures_value()
	reveal()


func _on_mouse_entered():
	if not OS.get_name() == 'Windows':
		return
	if not Globals.enable_animations:
		return
	if disabled || is_flagged:return
	$MainPivot/Pivot/HexagonTexture.self_modulate = tile_color_revealed


func _on_mouse_exited():
	if not OS.get_name() == 'Windows':
		return
	if not Globals.enable_animations:
		return
	$MainPivot/Pivot/HexagonTexture.self_modulate = tile_color



func _on_button_down():
	$Timer.start()


func _on_button_up():
	$Timer.stop()


func switch_flag():
	if not is_flagged:
		$AudioStreamPlayer2.pitch_scale = randf_range(1.2, 1.3)
		if Globals.enable_animations:
			create_tween().tween_property($MainPivot/PivotFlag, 'scale', Vector2(1, 1), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		else:
			$MainPivot/PivotFlag.scale = Vector2(1, 1)
		is_flagged = true
	else:
		$AudioStreamPlayer2.pitch_scale = randf_range(0.7, 0.8)
		if Globals.enable_animations:
			create_tween().tween_property($MainPivot/PivotFlag, 'scale', Vector2(0, 0), 0.5).set_ease(Tween.EASE_IN)
		else:
			$MainPivot/PivotFlag.scale = Vector2(0, 0)
		is_flagged = false
	$AudioStreamPlayer2.play()
	cell_flagged.emit(is_flagged)


func _on_timer_timeout():
	ignore_click = true
	if Globals.enable_vibration:
		Input.vibrate_handheld(50)
	switch_flag()
