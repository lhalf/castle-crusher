extends RigidBody

export var mouse_sensitivity = 0.1
var count = 0
export var base_cannonball_speed = 80
var rotation_count = 0
export var update_count = 5
export var rotation_update_count = 3
var saved_transform = null
var saved_angular_velocity = null
var saved_linear_velocity = null
var saved_x_rotation = null
var saved_y_rotation = null
var placed
var spawn_offset = Vector3(0,0.5,0)

remotesync func _shoot(speed,target):
	var cannonball = preload("res://scenes/objects/cannon/cannonball.tscn").instance()
	$horizontal_pivot/vertical_pivot/barrel/muzzle.add_child(cannonball)
	cannonball.look_at(target, Vector3.UP)
	cannonball.speed = speed
	cannonball.shot = true
	$horizontal_pivot/vertical_pivot/barrel/muzzle/cannonshot.stop()
	$horizontal_pivot/vertical_pivot/barrel/muzzle/cannonshot.play()
	$horizontal_pivot/vertical_pivot/barrel/muzzle/explosion.restart()
	$horizontal_pivot/vertical_pivot/barrel/muzzle/explosion.emitting = true

func _input(event):
	if event is InputEventMouseMotion and str(get_tree().get_network_unique_id()) == get_parent().get_parent().name and $horizontal_pivot/vertical_pivot/barrel/Camera.current:
		rotation_count += 1
		$horizontal_pivot.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		$horizontal_pivot/vertical_pivot.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		$horizontal_pivot/vertical_pivot.rotation.x = clamp($horizontal_pivot/vertical_pivot.rotation.x, deg2rad(-5), deg2rad(60))
		if rotation_count == rotation_update_count:
			rpc_unreliable("sync_rotation",$horizontal_pivot/vertical_pivot.rotation.x,$horizontal_pivot.rotation.y)
			rotation_count = 0

func _process(_delta):
	if Input.is_action_just_pressed("tap") and str(get_tree().get_network_unique_id()) == get_parent().get_parent().name and $horizontal_pivot/vertical_pivot/barrel/Camera.current and !$switch.pressed:
		$power_bar.show()
	if Input.is_action_just_released("tap") and str(get_tree().get_network_unique_id()) == get_parent().get_parent().name and $horizontal_pivot/vertical_pivot/barrel/Camera.current and $power_bar.visible:
		$power_bar.hide()
		rpc("_shoot",base_cannonball_speed*$power_bar.power_multiplier,$horizontal_pivot/vertical_pivot/barrel/muzzle/aimcast.get_collision_point())

func _on_switch_pressed():
	if !$horizontal_pivot/vertical_pivot/barrel/Camera.current:
		switch_to_cannon_view()
	else:
		switch_from_cannon_view()

func switch_to_cannon_view():
	$horizontal_pivot/vertical_pivot/barrel/Camera.current = true
	$horizontal_pivot/vertical_pivot/barrel/muzzle/crosshair.show()
	get_parent().get_parent().get_node("build_camera").get_node("build_menu").hide()
	get_parent().get_parent().get_node("build_camera").get_node("build_menu").get_node("controls").hide()

func switch_from_cannon_view():
	$horizontal_pivot/vertical_pivot/barrel/muzzle/crosshair.hide()
	get_parent().get_parent().get_node("build_camera").current = true
	get_parent().get_parent().get_node("build_camera").get_node("build_menu").show()
	get_parent().get_parent().get_node("build_camera").get_node("build_menu").get_node("controls").show()

func _ready():
	self.set_can_sleep(true)
	if str(get_tree().get_network_unique_id()) == get_parent().get_parent().name:
		$switch.show()
		
		#DEBUG
		#if get_parent().get_parent().get_node("build_camera").get_node("build_menu").get_node("timer").get_node("timer").is_stopped():
		#	switch_to_cannon_view() 

func _integrate_forces(state):
	if str(get_tree().get_network_unique_id()) == get_parent().get_parent().name and placed:
		count += 1
		#if !self.is_sleeping() and count == update_count:
		if count == update_count:
			rpc_unreliable("sync_state",state.get_transform(),state.get_angular_velocity(),state.get_linear_velocity())
			count = 0
	elif get_tree().get_network_unique_id() != 1:
		if saved_transform != null and saved_angular_velocity != null and saved_linear_velocity != null:
			state.set_transform(saved_transform)
			state.set_angular_velocity(saved_angular_velocity)
			state.set_linear_velocity(saved_linear_velocity)
			saved_transform = null
			saved_angular_velocity = null
			saved_linear_velocity = null

remote func sync_state(transform,angular_velocity,linear_velocity):
	saved_transform = transform
	saved_angular_velocity = angular_velocity
	saved_linear_velocity = linear_velocity

remote func sync_rotation(x_rotation,y_rotation):
	$horizontal_pivot/vertical_pivot.rotation.x = x_rotation
	$horizontal_pivot.rotation.y = y_rotation

func make_transparent():
	var transparent_material = SpatialMaterial.new()
	transparent_material.flags_transparent = true
	transparent_material.albedo_color = Color($mesh.mesh.material.albedo_color.r8, $mesh.mesh.material.albedo_color.g8, $mesh.mesh.material.albedo_color.b8, 0.5)
	$mesh.material_override = transparent_material
	$horizontal_pivot/vertical_pivot/barrel.material_override = transparent_material
