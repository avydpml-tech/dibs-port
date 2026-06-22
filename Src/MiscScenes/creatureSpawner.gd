extends Node2D

export (String) var mon_name = ""
export (String) var interacted_by = ""
export (bool) var one_shot = true

var from_creature_chamber = false
var Nonplayer_dict = {}

func _ready():
	if not interacted_by == "":
		add_to_group(interacted_by)
	$fadeInPlayer.play("fade_in")


func _interacted_by_obj():
	pass



func spawn_creature_in_chamber(name, know_where_player_is = false):
	var Nonplayer_dir = get_creature_dir(name)
	
	if Nonplayer_dir == "file does not exist": return
	
	var entity = load(Nonplayer_dir).instance()
	var spawn_posi = get_owner().get_node("SpawnPoint/Position2D")
	var player = Globals.get_player()


	if entity.is_stationary:
		var above_player = player.global_position + Vector2(0, - 100)
		entity.global_position = player.global_position if entity.gravity_enabled else above_player
	else:
		entity.global_position = spawn_posi.global_position

	
	if know_where_player_is:
		entity.player = player

	get_owner().get_node("SpawnPoint").add_child(entity)
	
	entity.set_owner(self.get_owner())
	entity.allow_hit_sound = false
	entity.should_sauce_mox = true
	entity.take_damage(1, Vector2( - 1, 0))
	entity.flashed_by_flashlight()

	
	
	
	
	
	
	
	
	
	
	

	
	
	

	
	

	
	
	
	

	
	
	
	


func disable():
	queue_free()


func update_creature(creature_name):
	mon_name = creature_name
	from_creature_chamber = true
	update_icon()



var icon_creature = null
func update_icon():
	if not icon_creature == null:
		icon_creature.queue_free()
	icon_creature = null
	show_creature(mon_name)


func show_creature(creature_name):
	var Nonplayer_dir = get_creature_dir(creature_name)
	
	if Nonplayer_dir == "file does not exist": return
	
	var entity = load(Nonplayer_dir).instance()
	entity.modulate = Color(100, 100, 100, 0.76)
	entity.is_disabled = true
	entity.disable_creature()
	$CreatureIcon.call_deferred("add_child", entity)

	icon_creature = entity

func get_creature_dir(creature_name):
	
	
	
	
	var Nonplayer_file_name = "f_" + creature_name
	var prelim = "res://Src/Entities/Nonplayer/f_subtypes/"

	
	

	var Nonplayer_dir = prelim + Nonplayer_file_name + "/" + Nonplayer_file_name + ".tscn"
	
	var dir = Directory.new()
	if not dir.file_exists(Nonplayer_dir):
		Nonplayer_dir = "file does not exist"
	
	return Nonplayer_dir
