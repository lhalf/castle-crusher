extends Polygon2D

var power_bar_offset = 100
var power_multiplier = 0
var power_multiplier_speed = 0.03
var power_direction = "up"
var size_y

func _ready():
	size_y = get_viewport().size.y

func _process(_delta):
	
	#if self.polygon != PoolVector2Array([
	#	Vector2(0,0),
	#	Vector2(0,get_viewport().size.y-power_bar_offset),
	#	Vector2(power_bar_offset,get_viewport().size.y-power_bar_offset),
	#	Vector2(power_bar_offset,0)
	#]):
	#	self.polygon = PoolVector2Array([
	#		Vector2(0,0),
	#		Vector2(0,get_viewport().size.y-power_bar_offset),
	#		Vector2(power_bar_offset,get_viewport().size.y-power_bar_offset),
	#		Vector2(power_bar_offset,0)
	#		])
	
	if self.visible:
		
		if power_multiplier > 1:
			power_direction = "down"
		if power_multiplier < 0:
			power_direction = "up"
		
		if power_direction == "up":
			power_multiplier += power_multiplier_speed
		if power_direction == "down":
			power_multiplier -= power_multiplier_speed
		
		$current_power.polygon = PoolVector2Array([
		 Vector2(0, size_y),
		 Vector2(power_bar_offset, size_y),
		 Vector2(power_bar_offset,( (1-power_multiplier) * (size_y - (power_bar_offset) ) )),
		 Vector2(0,( (1-power_multiplier) * (size_y - (power_bar_offset) ) ))
		])
	else:
		power_multiplier = 0
