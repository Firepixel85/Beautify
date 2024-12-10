extends AnimationPlayer
var anim:bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if anim:
		play("loop")
	
	

func _on_animation_finished(anim_name: StringName) -> void:
	_ready()
