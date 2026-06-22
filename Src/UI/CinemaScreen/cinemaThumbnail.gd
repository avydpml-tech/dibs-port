extends TextureButton

export (String) var cinema_name_nsfw
export (String) var cinema_name_sfw
export (Resource) var thumbnail_nsfw
export (Resource) var thumbnail_sfw
var is_sfw: bool = false

func _ready():
	set_thumbnail()
	$thumbnail.visible = not disabled

func _on_self_pressed():
	if SettingsManager.is_sfw_mode:
		get_owner().play_tape(cinema_name_sfw)
	else:
		get_owner().play_tape(cinema_name_nsfw)


func set_thumbnail():
	if SettingsManager.is_sfw_mode and thumbnail_sfw != null:
		$thumbnail.set_texture(thumbnail_sfw)
	else:
		$thumbnail.set_texture(thumbnail_nsfw)