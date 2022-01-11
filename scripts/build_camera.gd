extends Camera

var transparent_object
var objects_placed = 0
var placing_object = false
var touch_offset = Vector2(100,100)

remotesync func _add_object(index,translation,name):
	var object = $build_menu.object_array[index].instance()
	object.placed = true
	object.name = name
	get_parent().get_node("build_list").add_child(object)
	object.translation = translation + object.spawn_offset

remotesync func _remove_object():
	get_parent().get_node("build_list").get_children().back().free()

func _physics_process(_delta):
	#DEBUG
	if get_parent().name == "100":
		return
		
	#check we are the network owner of this node first,
	#this way no one else can sample inputs but us
	if get_parent().name == str(get_tree().get_network_unique_id()):
		#next, if we are currently using this camera we are in 
		#building mode, therefore we can sample for touch inputs
		if self.current:
			if Input.is_action_just_pressed("tap") and $build_menu.select_pressed:
				_spawn_transparent_object($build_menu.object_array_index)
				placing_object = true
			if Input.is_action_pressed("tap") and placing_object:
				_move_transparent_object(_grab_raycast_translation(touch_offset) + transparent_object.spawn_offset)
			if Input.is_action_just_released("tap") and placing_object:
				_destroy_transparent_object()
				objects_placed += 1
				placing_object = false
				rpc("_add_object",$build_menu.object_array_index,_grab_raycast_translation(touch_offset),str(get_tree().get_network_unique_id()+objects_placed))
				#if we place a cannon, skip forward in selection menu by 1 - this is quite messy, think about changing
				if _cannon_check() and $build_menu.object_array[$build_menu.object_array_index] == $build_menu.cannon:
					$build_menu/objects.get_child($build_menu.object_array_index).hide()
					$build_menu.object_array_index += 1
					$build_menu/objects.get_child($build_menu.object_array_index).show()
			#remove last placed object, should only be available when at least 1 object
			#assuming the last placed object will always be the last in the build array, so pop_back should work
			#first step controls whether the undo button is visible or not
			if get_parent().get_node("build_list").get_child_count() > 0 and !$build_menu/controls/undo.visible:
				$build_menu/controls/undo.show()
			elif get_parent().get_node("build_list").get_child_count() == 0 and $build_menu/controls/undo.visible:
				$build_menu/controls/undo.hide()
			#next remove objects if the button is pressed
			if Input.is_action_just_pressed("tap") and $build_menu.undo_pressed:
				rpc("_remove_object")

func _get_cannon_object():
	for p in get_parent().get_node("build_list").get_children():
		if p.has_method("_shoot"):
			return p

func _cannon_check():
	for p in get_parent().get_node("build_list").get_children():
		if p.has_method("_shoot"):
			return true
	return false
	
	#we check what index of the object array we are currently
	#selecting, this on the network master device
		#for the object index, we want to use the actual objects
		#to represent them in the menu, so we will need to disable
		#their collision box
		#also so they don't cast a shadow disable shadows
		#finally, they shoudn't be visible to the other client
		#idea for this - create the menu as a seperate node,
		#in the ready func for build_cam, if network master
		#instance a menu to the build_cam
	
	#grab raycast location onto the 3d space, check that the raycast
	#is on the building platform too
	
	#whilst the item is held, a transparent effect would be nice
	#also we don't want it to knock anything else over,
	#so we could disable its collision box for instance
	
	#for the time being, anything placed will be moveable
	#locking might be a useful feature in the future
	
	#when placed we send an update via rpc to the other
	#clients version of us, that we placed a block in a certain spot

func _grab_raycast_translation(offset):
	var space_state = self.get_world().get_direct_space_state()
	var mouse_position = get_viewport().get_mouse_position() - offset
	var ray_length = 100
	
	var from = self.project_ray_origin(mouse_position)
	var to = from + self.project_ray_normal(mouse_position) * ray_length

	var collision_point = space_state.intersect_ray(from,to)
	
	if not collision_point.empty():
		return (collision_point.position - get_parent().translation).rotated(Vector3(0,1,0),get_parent().rotation.y)

func _spawn_transparent_object(index):
	transparent_object = $build_menu.object_array[index].instance()
	transparent_object.placed = false
	transparent_object.get_node("shape").disabled = true
	transparent_object.make_transparent()
	get_parent().add_child(transparent_object)

func _move_transparent_object(translation):
	transparent_object.translation = translation

func _destroy_transparent_object():
	transparent_object.free()
