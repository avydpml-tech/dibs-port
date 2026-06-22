extends Light2D

export (String, "none", "flicker", "subtle_flicker") var effect = "none"

func _ready():
	$AnimationPlayer.play(effect)

