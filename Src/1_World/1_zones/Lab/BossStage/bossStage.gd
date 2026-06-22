extends Node2D








export (String, "bright", "light", "dark") var day_or_night = "bright"
export (NodePath)onready var boss_inst = get_node(boss_inst)
export (NodePath)onready var tired_boss_background = get_node(tired_boss_background)

var newspaper_swat_count: int = 0 setget set_newspaper_swat_count
var has_accepted_ammo: bool = false

signal player_lost_BSD
signal player_lost_BHM
signal new_time
signal tired_boss_bg_set

func _ready():
	PosManager.place_player()
	Globals.get_player()._add_health(3)
	
	_show_newspaper_swat_icons()

	connect("player_lost_BSD", boss_inst, "player_lost")
	Globals.get_player().coom_count = 0
	emit_signal("new_time", day_or_night)

	
	if not Globals.is_tired_boss:
		emit_signal("tired_boss_bg_set")


func interacted():
	Globals.get_player().hide()


func set_newspaper_swat_count(new_value):
	newspaper_swat_count = new_value
	if newspaper_swat_count >= 3:
		Globals.get_player().disable_mox()
		emit_signal("player_lost_BSD")

	_show_newspaper_swat_icons()


func _show_newspaper_swat_icons():
	$Health / NewspaperHitCount / RolledNewspaper.visible = newspaper_swat_count >= 1
	$Health / NewspaperHitCount / RolledNewspaper2.visible = newspaper_swat_count >= 2
	$Health / NewspaperHitCount / RolledNewspaper3.visible = newspaper_swat_count >= 3


func _tired_boss_activate():
	
	if Globals.get_player().check_if_2_full_ammo() and not has_accepted_ammo:
		Globals.get_player().pop_front_mags(2)
		has_accepted_ammo = true

	
	if not has_accepted_ammo:
		Globals.get_player().emit_signal("tired_boss_denied")
		return
	
	Globals.is_tired_boss = not Globals.is_tired_boss

	
	emit_signal("tired_boss_bg_set")

	for light in get_tree().get_nodes_in_group("tired_boss_lights"):
		light.fade()
