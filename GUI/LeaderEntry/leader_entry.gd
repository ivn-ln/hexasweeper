extends PanelContainer

var score_position = 0
var player_name = ''
var score = 999.0


# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.dark_mode:
		self_modulate = Color.DIM_GRAY
	else:
		self_modulate = Color.WHITE
	if score_position=='1':
		self_modulate=Color.GOLD
	if score_position=='2':
		self_modulate=Color.SILVER
	if score_position=='3':
		self_modulate=Color.CORAL
	$LeaderEntry/HBoxContainer2/Position.text = score_position
	$LeaderEntry/HBoxContainer2/Name.text = player_name
	$LeaderEntry/HBoxContainer2/Score.text = str(score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
