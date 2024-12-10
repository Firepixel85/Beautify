extends Sprite2D
@onready var viewport: SubViewport = $"../../SubViewport2"



func _process(delta: float) -> void:
	texture = viewport.get_texture()
