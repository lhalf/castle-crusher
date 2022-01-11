extends Camera

export var rotation_speed = 0.001

func _process(_delta):
	self.rotation.y += rotation_speed
