extends Control

@onready var album_art: TextureRect = $AlbumArt
var window_dim:Vector2
var past_texture = false


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	window_dim = get_window().size

func _process(delta: float) -> void:
	var resize_pass:bool 
	if past_texture == null and album_art.texture != null and  resize_pass == false:
		WindowFunctions.change_window_size(880,window_dim.y,get_window())
		resize_pass = true
		var timer = get_tree().create_timer(0.01)
		await timer.timeout
		WindowFunctions.change_window_size(window_dim.x,window_dim.y,get_window())
	if album_art.size.x <= 720:
		custom_minimum_size.y = size.x
		album_art.size.x = size.x/10 * 9

	if album_art.position.x > 39.39999:
		album_art.position.x = 39.39999
	elif album_art.size.x != 39.3999:
		album_art.position.x = (size.x - album_art.size.x)/2

	past_texture = album_art.texture
