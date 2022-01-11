extends Control

func _process(_delta):
	#DEBUG
	if get_parent().get_parent().get_parent().name == "100":
		return
	if get_tree().get_network_unique_id() != 1:
		$timer_label.text = str(int($timer.time_left))
