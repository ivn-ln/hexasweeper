extends Node2D

@export var grid_size = Vector2(6, 6)
@export_range(16, 256) var cell_size = 128
@export var starting_cell_coords = Vector2(2, 5)
@export var set_start_auto = true
@export_range(1, 99, 1) var treasures_amount = 20
@export_range(1, 99, 1) var mana_amount = 5
@export_range(0.0, 1.0, 0.01) var positive_chance = 0.0
var cell = preload('res://Scenes/Cell/cell.tscn')
var cells_array = []
var drag_mouse_start_pos = Vector2()
@onready var grid = $GridPivot/Grid
var chosen_cells = []
var cells_array_not_sorted = []
var are_treasures_generated = false
@onready var camera = $CameraPivot/Camera2D
var mines_amount = 0
var flags_amount = 0
var current_time = 0.0
var timer_started = false
var exploded_cell
var handling_input = true:
	set(value):
		handling_input = value
		for c in cells_array:
			if not handling_input:
				c.disabled = true
			else:
				c.disabled = false
var is_mana_generated = false
var color_palette = ['00cf7f', 'cf9100', 'cf0000', '00cbcf', '8a00cf', 'cf0091']
var current_color_palette = color_palette.duplicate()
var chosen_color
var inner_timer = 0.0
var min_camera_zoom = 1.0


func _ready():
	if OS.get_name() == 'Web':
		$CanvasLayer/FireworkBG.hide()
	match Globals.current_difficulty:
		'Easy':
			grid_size = Vector2(6, 6)
		'Medium':
			grid_size = Vector2(12, 12)
		'Hard':
			grid_size = Vector2(24, 24)
	if Globals.DEBUG:
		$CanvasLayer/FPS.show()
	grid_size += Vector2(1,1)
	var amount = max(1, grid_size.x * grid_size.y * treasures_amount * 0.01)
	mines_amount = int(amount)
	reset_hud_elements()
	set_colors()
	generate_grid()
	grid.global_position = Vector2(0, -get_viewport_rect().size.y/2) - grid_size / 2 * cell_size - Vector2(-cell_size/4 * grid_size.x/2, 0) - Vector2(cell_size/10.24, cell_size/10.24)
	set_camera_zoom_and_limits()
	-get_viewport_rect().size.y/2


func set_camera_zoom_and_limits():
	min_camera_zoom = Vector2(6.0, 6.0) * 1/max(grid_size.x, grid_size.y)*1.15 * 128 / cell_size
	camera.zoom = min_camera_zoom
	camera.global_position.y = -get_viewport_rect().size.y/2
	camera.limit_left = camera.global_position.x-get_viewport_rect().size.x/2*1/min_camera_zoom.x
	camera.limit_right = camera.global_position.x+get_viewport_rect().size.x/2*1/min_camera_zoom.x
	camera.limit_top = camera.global_position.y-get_viewport_rect().size.y/2*1/min_camera_zoom.x
	camera.limit_bottom = camera.global_position.y+get_viewport_rect().size.y/2*1/min_camera_zoom.x
	$Flame04.global_position = Vector2(camera.limit_left, camera.limit_top)
	$Flame05.global_position = Vector2(camera.limit_right, camera.limit_bottom)


func reset_hud_elements():
	$CanvasLayer/Mines/Amount/Mines.text = str(mines_amount - flags_amount)
	$CanvasLayer/Win.global_position.y = get_viewport_rect().size.y
	$CanvasLayer/GameOver.global_position.y = get_viewport_rect().size.y


func _process(delta):
	if not Globals.enable_audio:
		$AudioStreamPlayer3.volume_db = -90
		$AudioStreamPlayer.volume_db = -90
		$AudioStreamPlayer2.volume_db = -90
		$AudioStreamPlayer4.volume_db = -90
		$AudioStreamPlayer5.volume_db = -90
	else:
		$AudioStreamPlayer3.volume_db = -10
		$AudioStreamPlayer.volume_db = -20
		$AudioStreamPlayer2.volume_db = -20
		$AudioStreamPlayer4.volume_db = -10
		$AudioStreamPlayer5.volume_db = -20
	$CanvasLayer/Mines.visible = Globals.show_mines
	$CanvasLayer/Timer.visible = Globals.show_timer
	inner_timer += delta
	if Input.is_action_just_pressed("ui_accept"):
		grid_update_treasure_values(cells_array)
	if Input.is_action_just_pressed("Debug"):
		Globals.DEBUG = not Globals.DEBUG
		$CanvasLayer/FPS.visible = Globals.DEBUG
	if Input.is_action_just_pressed("Drag"):
		drag_mouse_start_pos = get_global_mouse_position()
	if Input.is_action_pressed("Drag"):
		var zoom_diff = (camera.zoom - min_camera_zoom).x
		camera.global_position = -(get_global_mouse_position() - camera.global_position) + drag_mouse_start_pos #- get_viewport_rect().size/2
		camera.global_position.x = clamp(camera.global_position.x, -zoom_diff * 32 * 32, zoom_diff * 32 * 32)
		camera.global_position.y = clamp(camera.global_position.y, -zoom_diff * 32 * 32 -get_viewport_rect().size.y/2, zoom_diff * 32 * 32 -get_viewport_rect().size.y/2)
	else:
		drag_mouse_start_pos = Vector2.ZERO
	if Input.is_action_just_released("ScaleDown"):
		camera.zoom *= 0.9
		camera.zoom.x = max(min_camera_zoom.x, camera.zoom.x)
		camera.zoom.y = camera.zoom.x
	if Input.is_action_just_released("ScaleUp"):
		camera.zoom *= 1.1
		camera.zoom.x = min(camera.zoom.x, 4.0)
		camera.zoom.y = camera.zoom.x
	$CanvasLayer/FPS.text = 'FPS ' + str(Engine.get_frames_per_second())
	if timer_started:
		current_time += delta
		update_timer_label()


func update_timer_label():
	var string = str(floori(current_time))
	var string_decimal = str(floorf(current_time*1000)/1000)
	$CanvasLayer/Timer.text = string



func generate_grid():
	var should_offset = false
	for l in range(grid_size.x):
		for r in range(grid_size.y):
			var cell_inst = cell.instantiate()
			cell_inst.name = str(r) + str(l)
			grid.add_child(cell_inst)
			cell_inst.base_scale = Vector2(cell_size, cell_size) / cell_inst.size
			cell_inst.scale = Vector2(cell_size, cell_size) / cell_inst.size# * Vector2(0.5, 1.0)
			cell_inst.global_position = grid.global_position + Vector2(l*cell_size, r*cell_size) + Vector2(-cell_size/4*l, int(should_offset) * cell_size/2)
			cell_inst.cell_pressed.connect(_on_cell_pressed)
			cell_inst.cell_flagged.connect(_on_cell_flagged)
			if not Globals.random_colors:
				cell_inst.tile_color = Color.from_string(chosen_color, Color.WHITE)
			else:
				cell_inst.tile_color = Color.from_string(color_palette.pick_random(), Color.WHITE)
			cells_array.append(cell_inst)
		should_offset = not should_offset
	cells_array_not_sorted = cells_array.duplicate()
	var starting_cell_inst = cell.instantiate()
	var l = starting_cell_coords.x
	var r = starting_cell_coords.y
	return
	if set_start_auto:
		starting_cell_inst.show_treasures_value()
		chosen_cells.append(starting_cell_inst)
		grid.add_child(starting_cell_inst)
		should_offset = true
		if int(starting_cell_coords.x) % 2 == 0:
			should_offset = false
		starting_cell_inst.scale = Vector2(cell_size, cell_size) / starting_cell_inst.size
		starting_cell_inst.global_position = grid.global_position + Vector2(l*cell_size, r*cell_size) + Vector2(-cell_size/4*l, int(should_offset) * cell_size/2)
		cells_array.append(starting_cell_inst)
		generate_treasures(treasures_amount, starting_cell_inst)
		cell_show_surrounding_treasures(starting_cell_inst, false)


func _on_cell_flagged(flag_status):
	if flag_status:
		flags_amount += 1
	else:
		flags_amount -= 1
	$CanvasLayer/Mines/Amount/Mines.text = str(mines_amount - flags_amount)


func generate_treasures(amount, start):
	amount = max(1, grid_size.x * grid_size.y * amount * 0.01)
	var avaliable_cells = cells_array.duplicate()
	for i in range(amount):
		randomize()
		var current_cell = avaliable_cells.pick_random()
		while current_cell == start:
			randomize()
			current_cell = avaliable_cells.pick_random()
		avaliable_cells.erase(current_cell)
		current_cell.is_treasure = true
	grid_update_treasure_values(cells_array)


func generate_mana(amount, start):
	amount = max(1, grid_size.x * grid_size.y * amount * 0.01)
	var avaliable_cells = cells_array.duplicate()
	for i in range(amount):
		randomize()
		var current_cell = avaliable_cells.pick_random()
		while current_cell == start || current_cell.is_treasure == true:
			randomize()
			current_cell = avaliable_cells.pick_random()
		avaliable_cells.erase(current_cell)
		current_cell.has_mana = true
	is_mana_generated = true


func cells_sort_by_distance(a, b):
	if a.global_position.distance_to(exploded_cell.global_position) < b.global_position.distance_to(exploded_cell.global_position):
		return true
	else:
		return false


func _on_cell_pressed(cell):
	if not handling_input: return
	if cell.is_flagged:return
	if not are_treasures_generated:
		timer_started = true
		are_treasures_generated = true
		#'Starting generation')
		generate_treasures(treasures_amount, cell)
		generate_mana(mana_amount, cell)
		#'Ending generation')
	chosen_cells.append(cell)
	#'Checking is cell a mine')
	exploded_cell = cell
	if await check_is_cell_mine(cell): return
	#'Checking surrounding cells')
	cell_show_surrounding_treasures(cell)
	#'Showing cell mines amount')
	cell.show_treasures_value()
	#'Checking is it a last cell')
	check_is_level_finished()


func check_is_cell_mine(cell):
	if cell.is_treasure:
		$AudioStreamPlayer3.pitch_scale = randf_range(0.7, 1.3)
		$AudioStreamPlayer3.play()
		$CanvasLayer/Restart.disabled = true
		$CanvasLayer/PauseButton.disabled = true
		for c in cells_array:
			c.disabled = true
		await reset_camera()
		exploded_cell = cell
		cells_array.sort_custom(cells_sort_by_distance)
		handling_input = false
		timer_started = false
		if Globals.enable_animations:
			$Shaker.start(2.5)
		for c in cells_array:
			if c.is_treasure and not c.is_revealed:
				c.reveal()
			c.roll()
			if not Globals.enable_animations:continue
			if should_wait > pow(grid_size.y,2)/40:
				await get_tree().create_timer(0.01).timeout
				should_wait = 0
			should_wait += 1
		if Globals.enable_animations:
			await get_tree().create_timer(0.5).timeout
			create_tween().tween_property($CanvasLayer/GameOver, 'global_position', Vector2.ZERO, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		else:
			$CanvasLayer/GameOver.global_position = Vector2.ZERO
		return true
	return false


func reset_camera():
	if Globals.enable_animations:
		create_tween().tween_property(camera, 'global_position', Vector2(0, -get_viewport_rect().size.y/2), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		await create_tween().tween_property(camera, 'zoom', min_camera_zoom, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).finished
	else:
		camera.global_position = Vector2(0, -get_viewport_rect().size.y/2)
		camera.zoom = min_camera_zoom
	return true


func check_is_level_finished():
	var is_finished = true
	for c in cells_array:
		if not c.is_revealed and not c.is_treasure:
			is_finished = false
	if is_finished:
		await reset_camera()
		$CanvasLayer/Restart.disabled = true
		$CanvasLayer/PauseButton.disabled = true
		timer_started = false
		var string = str(floori(current_time))
		var string_decimal = str(floorf(current_time*1000)/1000).substr(str(floorf(current_time*1000)/1000).find('.'))
		while string_decimal.length() < (grid_size.x + grid_size.y)/8:
			string_decimal += "0"
		string += string_decimal + "s"
		handling_input = false
		cells_array.sort_custom(cells_sort_by_distance)
		$AudioStreamPlayer4.pitch_scale = randf_range(0.7, 1.3)
		$AudioStreamPlayer4.play()
		for c in cells_array:
			c.roll()
			if not Globals.enable_animations:continue
			if should_wait > pow(grid_size.y,2)/20:
				await get_tree().create_timer(0.05).timeout
				should_wait = 0
			should_wait += 1
		$CanvasLayer/Win/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Timer.text = string
		if Globals.enable_animations:
			$CanvasLayer/Confetti/GPUParticles2D.emitting = true
			$AudioStreamPlayer2.play()
			await get_tree().create_timer(0.5).timeout
			create_tween().tween_property($CanvasLayer/FireworkBG, 'modulate', Color.WHITE, 1.0)
			create_tween().tween_property($CanvasLayer/Win, 'global_position', Vector2.ZERO, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		else:
			$CanvasLayer/Win.global_position = Vector2.ZERO

func set_colors():
	if Globals.current_color == null:
		if current_color_palette.size() <= 0:
			current_color_palette = color_palette.duplicate()
		var previous_color = chosen_color
		while previous_color == chosen_color:
			chosen_color = current_color_palette.pick_random()
		current_color_palette.erase(chosen_color)
	for c in cells_array:
		if not Globals.random_colors:
			if not Globals.enable_animations:
				c.tile_color = Color.from_string(chosen_color, Color.WHITE)
			else:
				create_tween().tween_property(c, 'tile_color', Color.from_string(chosen_color, Color.WHITE), 1.0)
		else:
			if not Globals.enable_animations:
				c.tile_color = Color.from_string(chosen_color, Color.from_string(color_palette.pick_random(), Color.WHITE))
			else:
				create_tween().tween_property(c, 'tile_color', Color.from_string(color_palette.pick_random(), Color.WHITE), 1.0)
	var color_class = Color.from_string(chosen_color, Color.WHITE)
	var color_processed = Color.from_hsv(color_class.h, color_class.s - 0.5, color_class.v + 0.2)
	if Globals.dark_mode:
		RenderingServer.set_default_clear_color(Color.BLACK)
		$CanvasLayer/Mines/Amount/Mines.theme_type_variation = 'DarkTheme'
		$CanvasLayer/Timer.theme_type_variation = 'DarkTheme'
		color_processed = Color.from_hsv(color_class.h, color_class.s - 0.5, color_class.v - 0.2)
	else:
		RenderingServer.set_default_clear_color(Color.WHITE)
		$CanvasLayer/Mines/Amount/Mines.theme_type_variation = ''
		$CanvasLayer/Timer.theme_type_variation = ''
		$CanvasLayer/Mines/Amount/Mines/TextureRect.self_modulate = Color.BLACK
		$CanvasLayer/Restart.self_modulate = Color.BLACK
		$CanvasLayer/PauseButton.self_modulate = Color.BLACK
	$CanvasLayer/Win/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Restart.self_modulate = color_processed
	$CanvasLayer/GameOver/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Restart.self_modulate = color_processed
	$CanvasLayer/Pause/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/Menu.self_modulate = color_processed
	$CanvasLayer/Win/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Leaders.self_modulate = color_class

func reset():
	await reset_camera()
	create_tween().tween_property($CanvasLayer/ReloadAsk, 'self_modulate', Color.TRANSPARENT, 0.5)
	handling_input = false
	are_treasures_generated = false
	chosen_cells.clear()
	current_time = 0.0
	update_timer_label()
	flags_amount = 0
	$CanvasLayer/Mines/Amount/Mines.text = str(mines_amount - flags_amount)
	timer_started = false
	randomize()
	create_tween().tween_property($CanvasLayer/FireworkBG, 'modulate', Color.TRANSPARENT, 1.0)
	if Globals.enable_animations:
		if $CanvasLayer/GameOver.global_position != Vector2(0, get_viewport_rect().size.y):
			await create_tween().tween_property($CanvasLayer/GameOver, 'global_position', -Vector2(0, get_viewport_rect().size.y), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK).finished
			$CanvasLayer/GameOver.global_position = Vector2(0, get_viewport_rect().size.y)
		if $CanvasLayer/Win.global_position != Vector2(0, get_viewport_rect().size.y):
			await create_tween().tween_property($CanvasLayer/Win, 'global_position', -Vector2(0, get_viewport_rect().size.y), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK).finished
			$CanvasLayer/Win.global_position = Vector2(0, get_viewport_rect().size.y)
	else:
		$CanvasLayer/GameOver.global_position = Vector2(0, get_viewport_rect().size.y)
		$CanvasLayer/Win.global_position = Vector2(0, get_viewport_rect().size.y)
	$AudioStreamPlayer5.pitch_scale = randf_range(0.7, 1.3)
	$AudioStreamPlayer5.play()
	for c in cells_array:
		c.reset()
		if not Globals.enable_animations:continue
		if should_wait > pow(grid_size.y,2)/20:
			await get_tree().create_timer(0.001).timeout
			should_wait = 0
		should_wait += 1
	handling_input = true
	$CanvasLayer/Restart.show()
	$CanvasLayer/PauseButton.show()
	$CanvasLayer/GameOver/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Restart.disabled = false
	$CanvasLayer/Win/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Restart.disabled = false
	$CanvasLayer/Restart.disabled = false
	$CanvasLayer/PauseButton.disabled = false
	set_colors()

var should_wait = 0
func cell_show_surrounding_treasures(cell, recursive = true):
	var surrounding_cells = cell_get_surrounding_cells(cell)
	for c in surrounding_cells:
		if c.is_revealed || c.is_treasure || c.is_flagged || c.disabled:
			continue
		c.show_treasures_value()
		if c.treasures_amount == 0:
			if not Globals.enable_animations:
				if should_wait > 256:
					await get_tree().create_timer(0.01).timeout
					should_wait = 0
				should_wait += 1
				_on_cell_pressed(c)
			else:
				if should_wait > pow(6,2)/200:
					await get_tree().create_timer(0.04).timeout
					should_wait = 0
				should_wait += 1
				_on_cell_pressed(c)


func cell_reveal_surrounding_treasures(cell):
	var surrounding_cells = cell_get_surrounding_cells(cell)
	for c in surrounding_cells:
		if c.is_revealed || c.is_flagged || c.disabled:
			continue
		cell_show_surrounding_treasures(c)
		_on_cell_pressed(c)


func cell_get_surrounding_cells(cell):
	var closest_cells = []
	var closest_position = 9999.0
	for c in cells_array:
		if c == cell:
			continue
		elif int(cell.global_position.distance_to(c.global_position)) == int(cell_size) or int(cell.global_position.distance_to(c.global_position)) == int(cell_size * 0.9):
			closest_cells.append(c)
	return closest_cells


func grid_update_treasure_values(cells_array):
	for c in cells_array:
		if c.is_treasure:
			continue
		var closest_cells = cell_get_surrounding_cells(c)
		var treasures_amount = 0
		for c_ in closest_cells:
			if c_.is_treasure:
				treasures_amount += 1
		treasures_amount += int(c.is_treasure)
		c.set_treasures_value(treasures_amount)


func _on_restart_pressed():
	$AudioStreamPlayer.play()
	cells_array = cells_array_not_sorted.duplicate()
	$CanvasLayer/GameOver/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Restart.disabled = true
	$CanvasLayer/Win/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Restart.disabled = true
	$CanvasLayer/Restart.disabled = true
	$CanvasLayer/PauseButton.disabled = true
	reset()
	


func _on_pause_button_pressed():
	$AudioStreamPlayer.play()
	#$CanvasLayer/PauseButton.disabled = true
	get_tree().paused = true
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property($CanvasLayer/Pause,'global_position' , Vector2(0,0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)


func _on_menu_pressed():
	$AudioStreamPlayer.play()
	get_parent().transition_to_menu()


func _on_leaders_pressed():
	$CanvasLayer/SubmitScore.score_value = floorf(current_time*1000)/1000
	$CanvasLayer/SubmitScore.show()


func _on_submit_score_score_submitted():
	$CanvasLayer/Leaders.show()
	$CanvasLayer/Leaders.update_scores()
