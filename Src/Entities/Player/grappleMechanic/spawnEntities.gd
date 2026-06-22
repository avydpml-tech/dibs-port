extends Node2D


func _ready():
	if get_parent().enable_creatures:
		load_gm_icons("walnut")
	else:
		repeat_check()


func repeat_check():
	if get_parent().entity_inst != null:
		load_gm_icons(get_parent().entity_inst.get_entity_name())
	elif get_parent().mon_name != "":
		load_gm_icons(get_parent().mon_name)
	else:
		queue_free()


func load_gm_icons(mon_grappled_name):
	
	
	
	var gm_icons_scene = "gm_" + mon_grappled_name
	var prelim = "res://Src/Entities/Player/grappleMechanic/subScenes/"

	var Nonplayer_loc = prelim + gm_icons_scene + "/" + gm_icons_scene + ".tscn"
	var Nonplayer = load(Nonplayer_loc).instance()
	
	add_child(Nonplayer)
