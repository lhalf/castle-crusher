extends TextureRect

var crosshair_offset = 20

func _process(_delta):
	if self.rect_position != Vector2( get_viewport().size.x/2-crosshair_offset, get_viewport().size.y/2-crosshair_offset ):
		self.rect_position = Vector2( get_viewport().size.x/2-crosshair_offset, get_viewport().size.y/2-crosshair_offset )
