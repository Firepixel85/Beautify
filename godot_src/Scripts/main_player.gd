extends Control

@onready var disconnected_icon = preload("res://Icons/disconnected_icon.png")
@onready var settings_window = preload("res://Pages/settings_page.tscn")
@onready var mouse_drag_component = preload("res://Scenes/mouse_drag.tscn")
@onready var song_title = $VBoxContainer/SongTitle
@onready var artist_name = $VBoxContainer/ArtistName
@onready var album_art = $VBoxContainer/Control/AlbumArt
@onready var album_art_container: Control = $VBoxContainer/Control

@onready var album_gradient = $AlbumGradient
@onready var settings_overlay = $SettingsOverlay
@onready var listen_on_spotify = $SettingsOverlay/ColorRect/MarginContainer2/ListenOnSpotifyButton
@onready var settings_button = $SettingsOverlay/ColorRect/SettingsButton
@onready var close_button = $SettingsOverlay/ColorRect/CloseButton
@onready var art_blocker = $GradientBlocker
var current_song_url = ""
enum { SUCCESS, LOADING, NOT_PLAYING }

var song_name 
var artist
var album 

func get_refresh_token():
	return ApplicationStorage.get_data(ApplicationStorage.Settings.REFRESH_TOKEN)


func get_access_token():
	return ApplicationStorage.get_data(ApplicationStorage.Settings.ACCESS_TOKEN)


var access_token = ""

var old_link = ""

var current_text_style = ""

var mouse_is_on_player = false
var external_url_is_valid = false


# Called when the node enters the scene tree for the first time.
func _ready():
	WindowFunctions.window_resizable(true, get_window())
	SongManager.number_of_sessions += 1
	song_title.change_text("Try Playing something from Spotify.")
	access_token = get_access_token()
	settings_overlay.modulate = Color.TRANSPARENT
	


	get_viewport().mouse_entered.connect(_on_mouse_enter)
	get_viewport().mouse_exited.connect(_on_mouse_exit)
	
	var win_height = ApplicationStorage.get_data(ApplicationStorage.Settings.WIN_HEIGHT)
	var win_width = ApplicationStorage.get_data(ApplicationStorage.Settings.WIN_WIDTH)
	var win_pos_x = ApplicationStorage.get_data(ApplicationStorage.Settings.WIN_POS_X)
	var win_pos_y = ApplicationStorage.get_data(ApplicationStorage.Settings.WIN_POS_Y)
	
	WindowFunctions.set_up_min_window_size(get_window())
	WindowFunctions.change_window_position(800,win_height,get_window())
	WindowFunctions.change_window_size(win_width, win_height-56, get_window())
	WindowFunctions.change_window_position(win_pos_x, win_pos_y, get_window())

	var borderless = ApplicationStorage.get_data(ApplicationStorage.Settings.BORDERLESS)
	listen_on_spotify.pressed.connect(open_ext_url)

	settings_button.pressed.connect(open_settings)

	ApplicationStorage.on_settings_change.connect(on_settings_change)

	ApplicationStorage.force_emit_data()

	SongManager.on_song_change.connect(change_displayed_data)

	WindowFunctions.change_window_borderless(borderless, get_window())
	var drag = mouse_drag_component.instantiate()
	drag.get_node("ColorRect").current_window = get_window()
	add_child(drag)

	close_button.pressed.connect(
		func():
			get_tree().quit()
	)


func convert_textstyle_to_text(textstyle: String, song_data: Dictionary) -> String:
	song_name = song_data.name
	artist = song_data.artist_name
	album = song_data.album_name

	var final_string = (
		textstyle
		. replace("`{song}`", song_name)
		. replace("`{artist}`", artist)
		. replace("`{album}`", album)
	)

	return final_string


func change_displayed_data(play_data: SongManager.PlayerData):
	external_url_is_valid = false

	if play_data.player_state == SongManager.PlayerState.SUCCESS:
		var data = play_data.data

		external_url_is_valid = true
		current_song_url = data.external_url
		var title = convert_textstyle_to_text(current_text_style, data)
		song_title.change_text(song_name)
		artist_name.change_text(artist)
		WindowFunctions.change_window_title(title, get_window())
		if old_link != current_song_url:
			var texture = ImageTexture.new()
			texture.set_image(data.img)
			var gred = generate_gradient(data.img)
			album_gradient.update_shader(texture)
			album_art_container.update_texture(texture)

			old_link = current_song_url
		return

	if play_data.player_state == SongManager.PlayerState.RATE_LIMIT_OVERLOADED:
		song_title.change_text(
			"Servers are currently too busy. Attempting to retry connection..."
		)

	if play_data.player_state == SongManager.PlayerState.LOADING:
		song_title.change_text("Loading Song...")

	if play_data.player_state == SongManager.PlayerState.OFFLINE:
		song_title.change_text("Not Connected. Attempting To Reconnect")
		if album_art.texture != disconnected_icon:
			transition_art_texture(album_art, "texture", disconnected_icon)

			var gradient = GradientTexture2D.new()
			var gradientValues = Gradient.new()

			gradientValues.set_color(0, Color.BLACK)
			gradientValues.set_color(1, Color.BLACK)

			gradient.gradient = gradientValues

			transition_art_texture(album_gradient, "texture", gradient)
		return

	if play_data.player_state == SongManager.PlayerState.NO_SPOTIFY_SESSIONS:
		song_title.change_text("Try Playing something from Spotify.")
		return


func on_settings_change(new_settings):
	# Alawys Pin to Top Setting:
	var is_pinned = ApplicationStorage.filter_emit_data(
		new_settings, ApplicationStorage.Settings.PIN_TO_TOP
	)

	
	WindowFunctions.change_window_always_on_top(is_pinned, get_window())

	# Player Speed Setting:
	var player_speed = ApplicationStorage.filter_emit_data(
		new_settings, ApplicationStorage.Settings.SPEED_OF_SONG
	)
	var speed_binding = (
		ApplicationStorage
		. get_settings_bindings(ApplicationStorage.Settings.SPEED_OF_SONG)[player_speed]
	)
	var speed_of_song = speed_binding.value

	song_title.speed_of_text = speed_of_song

	# Adaptive Gradient:
	var adaptive_background = ApplicationStorage.filter_emit_data(
		new_settings, ApplicationStorage.Settings.ADAPTIVE_BACKGROUND
	)	

	art_blocker.visible = !adaptive_background

	# Text Style Settings
	var text_style = ApplicationStorage.filter_emit_data(
		new_settings, ApplicationStorage.Settings.STYLE_OF_TEXT
	)
	var text_style_binding = (
		ApplicationStorage
		. get_settings_bindings(ApplicationStorage.Settings.STYLE_OF_TEXT)[text_style]
	)

	if text_style == ApplicationStorage.StyleOfText.CUSTOM:
		current_text_style = ApplicationStorage.filter_emit_data(
			new_settings, ApplicationStorage.Settings.CUSTOM_TEXT_STYLE
		)
	else:
		current_text_style = text_style_binding.value


func open_settings():
	if (get_tree().get_root().has_node("Settings")):
		get_tree().get_root().get_node("Settings").move_to_foreground()
		return

	var window = settings_window.instantiate()

	window.title = "Bittify Miniplayer"
	
	get_tree().root.add_child(window)	


func pin_to_top_pressed(pinned_status):
	ApplicationStorage.modify_data(ApplicationStorage.Settings.PIN_TO_TOP, pinned_status)


func open_ext_url():
	if current_song_url == "":
		return
	OS.shell_open(current_song_url)


func _on_mouse_enter():
	mouse_is_on_player = true
	var tween = get_tree().create_tween()
	tween.tween_property(settings_overlay, "modulate", Color.WHITE, 0.25)


func _on_mouse_exit():
	var tween = get_tree().create_tween()
	tween.tween_property(settings_overlay, "modulate", Color.TRANSPARENT, 0.25)
	mouse_is_on_player = false


func transition_art_texture(
	texture_component: TextureRect, property_to_transit: String, object_to_trasit_to: Variant
):
	var tween = get_tree().create_tween()
	tween.tween_property(texture_component, "modulate", Color.TRANSPARENT, .5).set_trans(
		Tween.TRANS_CUBIC
	)
	tween.tween_property(texture_component, property_to_transit, object_to_trasit_to, 0)
	tween.tween_property(texture_component, "modulate", Color.WHITE, .25).set_trans(
		Tween.TRANS_CUBIC
	)


func generate_gradient(img: Image) -> GradientTexture2D:
	var gradient = GradientTexture2D.new()
	var gradientValues = Gradient.new()
	gradientValues.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	var img_size = img.get_size()
	gradientValues.offsets = [.1, .1, .3, .5, .7, .9]

	var colors = []
	for i in range(gradientValues.offsets.size() - 2):
		var offset_value = gradientValues.offsets[i]
		var pixel = img.get_pixel(img_size.x / 1.1, img_size.y * offset_value)
		colors.append(pixel)

	colors.append(Color.BLACK)
	colors.append(Color.BLACK)
	gradientValues.colors = colors

	gradient.fill_from = Vector2.ZERO
	gradient.fill_to = Vector2(0, 1)

	gradient.gradient = gradientValues
	return gradient


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SongManager.number_of_sessions -= 1
		var current_size = get_window().size
		var current_window_position = get_window().position
		ApplicationStorage.modify_data(
			ApplicationStorage.Settings.WIN_HEIGHT, current_size.y, false
		)
		ApplicationStorage.modify_data(ApplicationStorage.Settings.WIN_WIDTH, current_size.x, false)
		ApplicationStorage.modify_data(
			ApplicationStorage.Settings.WIN_POS_X, current_window_position.x, false
		)
		ApplicationStorage.modify_data(
			ApplicationStorage.Settings.WIN_POS_Y, current_window_position.y, false
		)
		WindowFunctions.focus_window()
		get_tree().root.move_to_foreground()
		get_parent().queue_free()
