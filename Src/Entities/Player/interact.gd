\
\
"\nThis script is dedicated to the player's interaction with the world.\n"













extends Node2D

onready var body_range = $interactRange
onready var player = get_parent()

signal interact

var interactive_body
var body_range_list = []
var interact_delay_timer





func _ready():
	add_timer("interact_delay_timer")
	interact_delay_timer = get_node("interact_delay_timer")
	interact_delay_timer.start(0.2)



func _input(event):
	
	if (player.player_state in ["saucied", "grappled", "afterglow", "reload"])\
	and body_range_list.size() > 0:
		return
	
	
	
	
	

	
	
	if event.is_action_pressed("ui_interact")\
	and interact_delay_timer.is_stopped():
		
		interact_delay_timer.start(0.2)

		if body_range_list == []: return

		if player.interact_in_groups:
			body_range_list = sort_order_of_execution(body_range_list)

			for body in body_range_list:
				body.interacted()
		else:
			
			body_range_list[0].interacted()



func _on_interactRange_body_entered(body):
	if is_interactive(body):
		body_range_list.append(body)
		connect_body("interact", body, "interacted")
		body._player_entered()


func _on_interactRange_body_exited(body):
	var i = body_range_list.find(body)
	
	
	if i != - 1:
		disconnect_body("interact", body, "interacted")
		body._player_exited()
		body_range_list.remove(i)







func sort_order_of_execution(arr: Array) -> Array:
	for element in arr:
		if element.is_in_group("Doors"):
			arr.push_back(element)
			arr.remove(arr.find(element))
	return arr
	

func has_interact_el(bd) -> bool:
	for entity in body_range_list:
		if is_interactive(bd):
			interactive_body = bd
			return true
	return false


func is_interactive(body) -> bool:
	return true if body.is_in_group("Interactable") else false



func connect_body(sig, body, sig_handler):
	connect(sig, body, sig_handler)
	
func disconnect_body(sig, body, sig_handler):
	disconnect(sig, body, sig_handler)

func add_timer( var self_name, var one_shot = true):
	var timer = Timer.new()
	timer.set_name(self_name)
	timer.one_shot = one_shot
	add_child(timer)
