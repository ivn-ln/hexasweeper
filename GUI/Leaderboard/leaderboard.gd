extends Control


var leader_entry = preload('res://GUI/LeaderEntry/leader_entry.tscn')
var leader_array = []


func _ready():
	pass

func update_scores():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(0).sw_get_scores_complete
	for l in leader_array:
		l.queue_free()
	leader_array.clear()
	update_scores_view(sw_result['scores'])


func update_scores_view(scores_array):
	for s in scores_array:
		var leader_entry_inst = leader_entry.instantiate()
		leader_entry_inst.score_position = str(scores_array.find(s) + 1)
		leader_entry_inst.player_name = s['player_name']
		leader_entry_inst.score = s['score']
		leader_array.append(leader_entry_inst)
		$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(leader_entry_inst)


func _on_hide_pressed():
	hide()
