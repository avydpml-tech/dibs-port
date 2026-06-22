



class_name Entity
extends KinematicBody2D


const UP = Vector2.UP

var vel
var GRAVITY = 34
var dir = "right" setget dir_changed







func checkNodeExists( var s: String):
	if not get_parent().has_node(s): return true
	else: return false

func get_class(): return "Entity"

func dir_changed(new_dir):
	dir = new_dir




				
func setDir( var new_dir: String):
	if dir == new_dir: return

	match new_dir:
		"left", "right": self.dir = new_dir
		"switch":
			if dir == "left": self.dir = "right"
			elif dir == "right": self.dir = "left"







func knock_back( var force: int, var global_pos):
	if global_position < global_pos:
		vel.x = - force
	if global_position > global_pos:
		vel.x = force










func add_timer( var self_name, var one_shot = true):
	var timer = Timer.new()
	timer.set_name(self_name)
	timer.one_shot = one_shot
	add_child(timer)
	
	
func saveObjects():
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		save()
	
func save():
	var save_dict = {
		"filename": get_filename(), 
		"parent": get_parent().get_path(), 
		"pos_x": position.x, 
		"pos_y": position.y, 
	}
	return save_dict
