extends Area2D


func _ready():
	pass

func _on_orangeHeart_body_entered(body: Node):
	if body.get_name() == "player":
		Globals.get_player().set_decrease_stamina_rate(0.5)
		queue_free()