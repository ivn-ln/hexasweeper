extends Node


var level_inst
var level = preload('res://Rooms/Test/test.tscn')
var menu = preload('res://GUI/Menu/menu.tscn')
var menu_inst


func _ready():
	menu_inst = $CanvasLayer/Menu
	menu_inst.enable_play_button()



func transition_to_game():
	level_inst = level.instantiate()
	add_child(level_inst)
	await create_tween().tween_property(menu_inst, 'modulate', Color.TRANSPARENT, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).finished
	menu_inst.queue_free()


func transition_to_menu():
	menu_inst = menu.instantiate()
	menu_inst.modulate = Color.TRANSPARENT
	$CanvasLayer.add_child(menu_inst)
	await create_tween().tween_property(menu_inst, 'modulate', Color.WHITE, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).finished
	menu_inst.enable_play_button()
	level_inst.queue_free()
