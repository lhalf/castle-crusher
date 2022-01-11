extends Spatial

func _process(delta):
	self.rotation_degrees.y += delta*10
