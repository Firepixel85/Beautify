extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("loop")
	
	

func _on_animation_finished(anim_name: StringName) -> void:
	_ready()
