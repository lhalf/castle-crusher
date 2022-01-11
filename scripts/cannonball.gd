extends RigidBody

var speed
var shot = false
var count = 0
export var update_count = 5
var saved_transform = null
var saved_angular_velocity = null
var saved_linear_velocity = null

func _integrate_forces(state):
	if str(get_tree().get_network_unique_id()) == get_parent().get_parent().name:
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

func _ready():
	set_as_toplevel(true)

func _physics_process(_delta):
	if shot:
		apply_impulse(transform.basis.z*speed, -transform.basis.z*speed)
		shot = false

func _on_timeout_timeout():
	queue_free()

func _on_collision_body_entered(_body):
	$timeout.start()
