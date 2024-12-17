extends Control

@onready var album_art: TextureRect = $AlbumArt
var window_dim:Vector2
var past_texture = false
@onready var animator: AnimationPlayer = $AlbumArt/AnimationPlayer


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	window_dim = get_window().size
	
	await get_tree().create_timer(1).timeout
	WindowFunctions.change_window_size(880,window_dim.y,get_window())
	var timer = get_tree().create_timer(0.01)
	await timer.timeout
	WindowFunctions.change_window_size(window_dim.x,window_dim.y,get_window())
	album_art.material.set_shader_parameter("opacity",1)

func _process(delta: float) -> void:
	album_art.pivot_offset = size/2
	if album_art.size.x <= 720:
		custom_minimum_size.y = size.x
		album_art.size.x = size.x/10 * 9

	if album_art.position.x > 39.39999:
		album_art.position.x = 39.39999
	elif album_art.size.x != 39.3999:
		album_art.position.x = (size.x - album_art.size.x)/2

	past_texture = album_art.texture


func update_texture(new_texture):
	album_art.flip_h = false
	album_art.material.set_shader_parameter("yDegrees",0)
	album_art.texture = new_texture

func change_song():
	album_art.material.set_shader_parameter("width",album_art.size.x)
	album_art.material.set_shader_parameter("height",album_art.size.y)
	animator.play("Change Song")

func pause_song():
	animator.play("Pause")
	
func play_song():
	animator.play("Play")
