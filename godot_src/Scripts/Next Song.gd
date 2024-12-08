extends Button

@export var oparation:String

func _pressed() -> void:
	if oparation == "next":
		SongManager.next_song()
	elif oparation == "previous":
		SongManager.previous_song()
	elif oparation == "pause_play":
		SongManager.pause_play_song()
