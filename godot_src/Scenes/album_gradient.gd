extends TextureRect
@onready var texture_renderer: SubViewport = $"../SubViewport"
@onready var texture_holder: TextureRect = $"../SubViewport/TextureRect"
var target

func _ready() -> void:
	target = texture
func _process(delta: float) -> void:
	var win_size = get_viewport().size
	position = Vector2(0,0)
	size = win_size
	pivot_offset = size/2
	texture = target
	

	
func update_shader(new_texture):

	texture_holder.visible = true
	texture_holder.material.set_shader_parameter("screen_texture",new_texture)
	texture_renderer.set_update_mode(SubViewport.UpdateMode.UPDATE_ONCE)
	target = texture_renderer.get_texture()
	await get_tree().create_timer(0.1).timeout
	texture_holder.visible = false
	

	

	
	
	
