extends Spatial

func _ready():
	
	#DEBUG
	if self.name == "100":
		return
		
	#by this point, joining player knows how many people are joined
	#could start timer on both players here, giving them time to build
	#also can do positioning of both players at this point
	#print(get_parent().get_children().size())
	if get_tree().get_network_unique_id() == 1:
		if get_parent().get_children().size() == 2:
			rpc("set_position",Vector3(0,0,-40),180)

remote func set_position(translation,rotation):
	self.translation = translation
	self.rotation_degrees.y = rotation
