extends TextureRect

func _process(delta: float) -> void:
	material.set_shader_parameter("source_texture",texture)

	
