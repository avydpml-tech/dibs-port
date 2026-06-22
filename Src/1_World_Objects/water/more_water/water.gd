extends TextureRect



func _ready():
	call_deferred("_set_collisions")
func _set_collisions():
	$player_death / collision.shape.extents = rect_size / 2.0
	$player_death.position = rect_size / 2.0























