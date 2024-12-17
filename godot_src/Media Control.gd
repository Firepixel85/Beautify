extends Button
@onready var animator: AnimationPlayer = $AnimationPlayer
@export var op:int
@onready var album_art_container: Control = $"../../Control"

var paused:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if op == 1:
		animator.play("Next")
	elif op == -1:
		animator.play("Previous")
	elif op == 0:
		animator.play("Play")
	else:
		push_error("dir value can only be -1 or 1!")


func _pressed() -> void:
	if op == 1:
		animator.play("Next")
		SongManager.next_song()
		album_art_container.change_song()
	elif op == -1:
		animator.play("Previous")
		SongManager.previous_song()
		album_art_container.change_song()
	elif op == 0:
		if paused == false:
			paused = true
			animator.play("Pause")
			SongManager.pause_play_song()
			album_art_container.pause_song()
		else:
			paused = false
			animator.play("Play")
			SongManager.pause_play_song()
			album_art_container.play_song()
	else:
		push_error("dir value can only be -1 or 1!")
