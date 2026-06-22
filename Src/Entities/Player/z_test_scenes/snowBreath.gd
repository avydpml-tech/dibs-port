extends Node2D


export (bool) var breath_active = true setget breath_visibility
export (int) var breath_timer_min = 10
export (int) var breath_timer_max = 10
export (String, MULTILINE) var NOTE = "THIS ONLY WORKS FOR PLYR AND ENTITIES"
export (int) var snow_breath_delay = 1

var entity = null
var accepted_bodies = ["PlayerChar", "Entity"]

func _ready():
	$Timer.start(1)
	if get_parent().get_class() in accepted_bodies:
		entity = get_parent()


func _process(_delta):
	pass


func breath_visibility(new_value):
	breath_active = new_value
	if breath_active and $Timer.is_stopped():
		$Timer.start(snow_breath_delay)
	elif not breath_active:
		$Timer.stop()


func emit_particles():
	for particle_child in get_children():
		if particle_child.get_class() in ["CPUParticles2D", "Particles2D"]:
			particle_child.emitting = true
		
func check_dir():
	if entity.dir == "left":
		rotation_degrees = 180
	elif entity.dir == "right":
		rotation_degrees = 0
			

	
func _on_Timer_timeout():
	if not breath_active: return

	if entity != null:
		check_dir()
	
	emit_particles()
	
	var rand_timer = rand_range(breath_timer_min, breath_timer_max)
	$Timer.start(rand_timer)
	
	