extends TextureButton


signal cell_pressed(cell)
signal cell_flagged(flag_status)
var treasures_amount = 0
var is_treasure_values_revealed = false
var is_revealed = false
var is_flagged = false

var is_treasure = false


func _ready():
	if not Globals.DEBUG: return
	show_treasures_value()


func _process(delta):
	$GPUParticles2D.process_material.scale_max = scale.x * 6 * 1.5
	$GPUParticles2D.process_material.scale_min = scale.x * 2 * 1.5


func set_treasures_value(value):
	treasures_amount = int(value)
	$Treasures.text = str(value)


func show_treasures_value():
	disabled = true
	reveal()
	self_modulate = Color.SLATE_GRAY
	$TextureRect3.hide()
	is_treasure_values_revealed = true
	if treasures_amount == 0:
		$Treasures.text = ''
	$Treasures.show()


func reveal():
	is_revealed = true
	if is_treasure:
		$GPUParticles2D.emitting = true
		self_modulate = Color.RED
		$Treasure.show()


func _on_pressed():
	if Input.is_action_just_released("Flag"):
		if not is_flagged:
			$TextureProgressBar.value = 100
			self_modulate = Color.MEDIUM_VIOLET_RED
			is_flagged = true
		else:
			$TextureProgressBar.value = 0
			self_modulate = Color.WHITE
			is_flagged = false
		cell_flagged.emit(is_flagged)
		return
	if is_flagged:
		return
	cell_pressed.emit(self)
	reveal()


func _on_mouse_entered():
	if is_treasure and is_revealed:
		return
	if is_flagged or disabled:
		return
	self_modulate = Color.DARK_SLATE_GRAY
	


func _on_mouse_exited():
	if is_treasure and is_revealed:
		return
	if is_flagged or disabled:
		return
	self_modulate = Color.WHITE

