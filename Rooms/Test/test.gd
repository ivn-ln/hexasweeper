extends Node2D

@export var grid_size = Vector2(5, 5)
@export var cell_size = Vector2(128, 128)
@export var starting_cell_coords = Vector2(2, 5)
@export var set_start_auto = true
@export_range(1, 99, 1) var treasures_amount = 20
@export_range(0.0, 1.0, 0.01) var positive_chance = 0.0
var cell = preload('res://Scenes/Cell/cell.tscn')
var cells_array = []
var drag_mouse_start_pos = Vector2()
@onready var grid = $Grid
var chosen_cells = []
var are_treasures_generated = false
@onready var camera = $Camera2D
var mines_amount = 0
var flags_amount = 0
var current_time = 0.0
var timer_started = false


func _ready():
	if Globals.DEBUG:
		$CanvasLayer/FPS.show()
	var amount = max(1, grid_size.x * grid_size.y * treasures_amount * 0.01)
	mines_amount = int(amount)
	$CanvasLayer/Mines/Amount/Mines.text = str(mines_amount) 
	generate_grid()
	camera.limit_left = camera.global_position.x-get_viewport_rect().size.x
	camera.limit_right = camera.global_position.x+get_viewport_rect().size.x
	camera.limit_top = camera.global_position.y-get_viewport_rect().size.y
	camera.limit_bottom = camera.global_position.y+get_viewport_rect().size.y





func _process(delta):
	if Input.is_action_just_pressed("Restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("ui_accept"):
		grid_update_treasure_values(cells_array)
	if Input.is_action_just_pressed("Debug"):
		Globals.DEBUG = not Globals.DEBUG
		$CanvasLayer/FPS.visible = Globals.DEBUG
	if Input.is_action_just_pressed("Drag"):
		drag_mouse_start_pos = get_global_mouse_position()
	if Input.is_action_pressed("Drag"):
		camera.global_position = -(get_global_mouse_position() - camera.global_position) + drag_mouse_start_pos #- get_viewport_rect().size/2
		camera.global_position.x = clamp(camera.global_position.x, camera.limit_left / 2, camera.limit_right/ 2)
		camera.global_position.y = clamp(camera.global_position.y, -1280, 0.0)
	else:
		drag_mouse_start_pos = Vector2.ZERO
	if Input.is_action_just_released("ScaleDown"):
		camera.zoom *= 0.9
		camera.zoom.x = max(0.5, camera.zoom.x)
		camera.zoom.y = camera.zoom.x
	if Input.is_action_just_released("ScaleUp"):
		camera.zoom *= 1.1
		camera.zoom.x = min(camera.zoom.x, 2.0)
		camera.zoom.y = camera.zoom.x
	$CanvasLayer/FPS.text = 'FPS ' + str(Engine.get_frames_per_second())
	if timer_started:
		current_time += delta
		var string = str(floori(current_time))
		var string_decimal = str(floorf(current_time*1000)/1000).substr(str(floorf(current_time*1000)/1000).find('.'))
		while string_decimal.length() < 4:
			string_decimal += "0"
		string += string_decimal + "s"
		$CanvasLayer/Timer.text = string


func generate_grid():
	var should_offset = false
	for l in range(grid_size.x):
		for r in range(grid_size.y):
			var cell_inst = cell.instantiate()
			grid.add_child(cell_inst)
			cell_inst.scale = cell_size / cell_inst.size# * Vector2(0.5, 1.0)
			cell_inst.global_position = grid.global_position + Vector2(l*cell_size.x, r*cell_size.y) + Vector2(-cell_size.x/4*l, int(should_offset) * cell_size.y/2)
			cell_inst.cell_pressed.connect(_on_cell_pressed)
			cell_inst.cell_flagged.connect(_on_cell_flagged)
			cells_array.append(cell_inst)
		should_offset = not should_offset
	var starting_cell_inst = cell.instantiate()
	var l = starting_cell_coords.x
	var r = starting_cell_coords.y
	if set_start_auto:
		starting_cell_inst.show_treasures_value()
		chosen_cells.append(starting_cell_inst)
		grid.add_child(starting_cell_inst)
		should_offset = true
		if int(starting_cell_coords.x) % 2 == 0:
			should_offset = false
		starting_cell_inst.scale = cell_size / starting_cell_inst.size
		starting_cell_inst.global_position = grid.global_position + Vector2(l*cell_size.x, r*cell_size.y) + Vector2(-cell_size.x/4*l, int(should_offset) * cell_size.y/2)
		cells_array.append(starting_cell_inst)
		generate_treasures(treasures_amount, starting_cell_inst)
		cell_show_surrounding_treasures(starting_cell_inst, false)


func _on_cell_flagged(flag_status):
	if flag_status:
		flags_amount += 1
	else:
		flags_amount -= 1
	$CanvasLayer/Mines/Amount/Flags.text = str(flags_amount)


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
	are_treasures_generated = true


func _on_cell_pressed(cell):
	if cell.is_flagged:return
	if not are_treasures_generated:
		timer_started = true
		generate_treasures(treasures_amount, cell)
	if cell.is_treasure:
		for c in cells_array:
			if c.is_treasure and not c.is_revealed:
				c.reveal()
		timer_started = false
		$CanvasLayer/GameOver.show()
		return
	chosen_cells.append(cell)
	cell_show_surrounding_treasures(cell)
	cell.show_treasures_value()
	var is_finished = true
	for c in cells_array:
		if not c.is_revealed and not c.is_treasure:
			is_finished = false
	if is_finished:
		timer_started = false
		var string = str(floori(current_time))
		var string_decimal = str(floorf(current_time*1000)/1000).substr(str(floorf(current_time*1000)/1000).find('.'))
		while string_decimal.length() < 4:
			string_decimal += "0"
		string += string_decimal + "s"
		$CanvasLayer/Win/Timer.text = string
		$CanvasLayer/Win.show()


func cell_show_surrounding_treasures(cell, recursive = true):
	var surrounding_cells = cell_get_surrounding_cells(cell)
	for c in surrounding_cells:
		if c in chosen_cells || c.is_treasure || c.is_flagged:
			continue
		c.show_treasures_value()
		if c.treasures_amount == 0:
			_on_cell_pressed(c)


func cell_reveal_surrounding_treasures(cell):
	var surrounding_cells = cell_get_surrounding_cells(cell)
	for c in surrounding_cells:
		if c in chosen_cells || c.is_flagged:
			continue
		cell_show_surrounding_treasures(c)
		_on_cell_pressed(c)


func cell_get_surrounding_cells(cell):
	var closest_cells = []
	var closest_position = 9999.0
	for c in cells_array:
		if c == cell:
			continue
		elif int(cell.global_position.distance_to(c.global_position)) == int(cell_size.x) or int(cell.global_position.distance_to(c.global_position)) == int(cell_size.x * 0.9):
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
	get_tree().reload_current_scene()
