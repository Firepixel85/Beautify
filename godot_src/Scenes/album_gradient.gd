extends TextureRect

func _process(delta: float) -> void:
	var shader_material = self.material
	shader_material.set_shader_parameter("screen_size", Vector2(get_viewport().size.x, get_viewport().size.y))
	shader_material.set_shader_parameter("screen_texture",texture)
	var win_size = get_viewport().size
	position = Vector2(0,0)
	size = win_size
	pivot_offset = size/2

	
func update_shader():
	material.set_shader_parameter("iChannel0",texture)
