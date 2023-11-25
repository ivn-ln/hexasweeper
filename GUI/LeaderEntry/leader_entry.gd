extends PanelContainer

var score_position = 0
var player_name = ''
var score = 999.0


# Called when the node enters the scene tree for the first time.
func _ready():
	$LeaderEntry/HBoxContainer2/Position.text = score_position
	$LeaderEntry/HBoxContainer2/Name.text = player_name
	$LeaderEntry/HBoxContainer2/Score.text = str(score) + 's'


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
