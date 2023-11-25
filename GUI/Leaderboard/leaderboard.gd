extends Control


var leader_entry = preload('res://GUI/LeaderEntry/leader_entry.tscn')
var leader_array = []


func _ready():
	pass

func update_scores(scoreboard = 'main', force_change=false):
	if force_change:
		match Globals.current_difficulty:
			'Easy':
				$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TabBar.current_tab = 0
			'Medium':
				$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TabBar.current_tab = 1
			'Hard':
				$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TabBar.current_tab = 2
		return
	$Control.show()
	for l in leader_array:
		l.queue_free()
	leader_array.clear()
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(0, scoreboard).sw_get_scores_complete
	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TabBar.set_tab_disabled(0, false)
	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TabBar.set_tab_disabled(1, false)
	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TabBar.set_tab_disabled(2, false)
	$Control.hide()
	update_scores_view(sw_result['scores'])


func update_scores_view(scores_array):
	for s in scores_array:
		var leader_entry_inst = leader_entry.instantiate()
		leader_entry_inst.score_position = str(scores_array.find(s) + 1)
		if s['player_name'] == Globals.player_id:
			leader_entry_inst.modulate = Color.from_string('00cf7f', Color.WHITE)
		leader_entry_inst.player_name = s['metadata']['display_name']
		leader_entry_inst.score = str(floorf((1 / (s['score']) * 1000 * 1000))/1000)
		leader_array.append(leader_entry_inst)
		$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer.add_child(leader_entry_inst)


func _on_hide_pressed():
	hide()


func _on_tab_bar_tab_changed(tab):
	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TabBar.set_tab_disabled(0, true)
	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TabBar.set_tab_disabled(1, true)
	$MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TabBar.set_tab_disabled(2, true)
	match tab:
		0:
			update_scores('main')
		1:
			update_scores('medium')
		2:
			update_scores('hard')
