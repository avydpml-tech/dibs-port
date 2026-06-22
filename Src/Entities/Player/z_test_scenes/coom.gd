extends Node2D
\
\
\
"\r\nAnother note: If it is dark, the smoke should be more prominent.\r\n\t\t\t\tI cant see it if it is dark.\r\n"


export (bool) var show = true
export (int) var breath_timer_min = 10
export (int) var breath_timer_max = 10
export (String) var NOTE = "THIS ONLY WORKS FOR PLYR AND ENTITIES"

var entity = null
var accepted_bodies = ["Woahman", "PlayerChar", "Nonplayer", "Entity"]

func _ready():
	$Timer.start(3)
	emit_particles()
	if get_parent().get_class() in accepted_bodies:
		entity = get_parent()
	pass

func _process(_delta):

	
	
	show() if show else hide()
	
func _on_Timer_timeout():
	call_deferred("free")
	
	if entity != null:
		check_dir()
	emit_particles()
	
	
	var rand_timer = rand_range(breath_timer_min, breath_timer_max)
	$Timer.start(rand_timer)
	
	
func emit_particles():
	for particle_child in get_children():
		if particle_child.get_class() == "CPUParticles2D":
			particle_child.emitting = true
		elif particle_child.get_class() == "Particles2D":
			particle_child.emitting = true
			
func check_dir():
	if entity.dir == "left":
		rotation_degrees = 180
	elif entity.dir == "right":
		rotation_degrees = 0
	rotation_degrees = 180
			
