extends Spatial

onready var cube = preload("res://scenes/objects/cube/cube.tscn")
onready var cylinder = preload("res://scenes/objects/cylinder/cylinder.tscn")
onready var cannon = preload("res://scenes/objects/cannon/cannon.tscn")
onready var object_array = [cube,cannon,cylinder]
var object_array_index = 0
var select_pressed = false
var undo_pressed = false

func _on_left_pressed():
	$objects.get_child(object_array_index).hide()
	if object_array_index != 0:
		object_array_index -= 1
		if get_parent()._cannon_check() and object_array[object_array_index] == cannon:
			object_array_index -= 1
	else:
		object_array_index = object_array.size() - 1
	$objects.get_child(object_array_index).show()

func _on_right_pressed():
	$objects.get_child(object_array_index).hide()
	if object_array_index != object_array.size() - 1:
		object_array_index += 1
		if get_parent()._cannon_check() and object_array[object_array_index] == cannon:
			object_array_index += 1
	else:
		object_array_index = 0
	$objects.get_child(object_array_index).show()

func _on_select_button_down():
	select_pressed = true

func _on_select_button_up():
	select_pressed = false

func _on_undo_button_down():
	undo_pressed = true

func _on_undo_button_up():
	undo_pressed = false

func force_cannon_in_menu():
	while object_array[object_array_index] != cannon:
		_on_left_pressed()
	$controls/left.hide()
	$controls/right.hide()

func _on_timer_timeout():
	$timer.hide()
	if get_parent()._cannon_check():
		print("hello")
		get_parent()._get_cannon_object().switch_to_cannon_view()
	else:
		force_cannon_in_menu()
