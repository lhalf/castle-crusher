extends Control

var arrow_offset = 75
var select_offset = 100
var undo_offset = 100

func _process(_delta):
	
	if $left.rect_position != Vector2( get_viewport().size.x/3-arrow_offset, 4*get_viewport().size.y/5-arrow_offset ):
		$left.rect_position = Vector2( get_viewport().size.x/3-arrow_offset, 4*get_viewport().size.y/5-arrow_offset )
	
	if $right.rect_position != Vector2( 2*get_viewport().size.x/3-arrow_offset, 4*get_viewport().size.y/5-arrow_offset ):
		$right.rect_position = Vector2( 2*get_viewport().size.x/3-arrow_offset, 4*get_viewport().size.y/5-arrow_offset )
	
	if $select.rect_position != Vector2( get_viewport().size.x/2-select_offset, 4*get_viewport().size.y/5-select_offset ):
		$select.rect_position = Vector2( get_viewport().size.x/2-select_offset, 4*get_viewport().size.y/5-select_offset )
	
	if $undo.rect_position != Vector2( get_viewport().size.x-undo_offset, 0 ):
		$undo.rect_position = Vector2( get_viewport().size.x-undo_offset, 0 )
