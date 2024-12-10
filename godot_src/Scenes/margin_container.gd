extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	remove_theme_constant_override("margin_left")
	remove_theme_constant_override("margin_right")
	var target_size = size.x - size.x/10 * 9
	print(target_size)
	add_theme_constant_override("margin_left",target_size)
	add_theme_constant_override("margin_right",target_size)
	
	
