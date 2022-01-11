extends RigidBody

var count = 0
export var update_count = 5
var saved_transform = null
var saved_angular_velocity = null
var saved_linear_velocity = null
var placed
var spawn_offset = Vector3(0,1,0)

func _ready():
	self.set_can_sleep(true)

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

func make_transparent():
	var transparent_material = SpatialMaterial.new()
	transparent_material.flags_transparent = true
	transparent_material.albedo_color = Color($mesh.mesh.material.albedo_color.r8, $mesh.mesh.material.albedo_color.g8, $mesh.mesh.material.albedo_color.b8, 0.5)
	$mesh.material_override = transparent_material
