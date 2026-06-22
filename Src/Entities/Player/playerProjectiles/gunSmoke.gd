extends Particles2D

func _ready():
	emitting = true
	
	
	var queue_timer = Timer.new()
	queue_timer.connect("timeout", self, "_on_queue_timer_timeout")
	add_child(queue_timer)
	queue_timer.start(6)

func _on_queue_timer_timeout():
	call_deferred("free")
