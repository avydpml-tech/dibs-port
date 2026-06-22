extends Node






signal tape_picked_up(tape_name)
signal had_saucy(entity)
signal plant_cleared
signal dutiful_citizen_fulfilled
signal janitor_achieved

signal snack_found
signal snack_given
signal scarf_found
signal scarf_given
signal newspaper_found

signal achievements_reset

func _ready():
	connect("had_saucy", self, "had_saucy")









var saucy_counter = 0
var saucy_types = {}

func had_saucy(_entity = null):
	_increment_saucy_types("tentacles")
	saucy_counter += 1


func _increment_saucy_types(type):
	if not saucy_types.has(type):
		saucy_types[type] = 1
	else:
		saucy_types[type] += 1





var collected_tapes = []
var completed_tapes = ["tentacle1", "koubold1", "tentacle2", "tentacle3", "woof1", "train", "meetup", "boss"]


func auto_complete_cinema():
	collected_tapes = completed_tapes


func reset_cinema():
	collected_tapes = []


func tape_found(tape_name):
	collected_tapes.append(tape_name)
	self.emit_signal("tape_picked_up", tape_name)


func get_collected_tapes():
	return collected_tapes


func get_num_of_cinema_tapes() -> int:
	return collected_tapes.size()





var is_vending_machine_empty = false
var snack_arr = []
var koubold_snack_given_arr = []

func is_snack_empty():
	return snack_arr == []


func snack_found(food: String = ""):
	if food == null or food == "":
		snack_arr.append("food")
	self.emit_signal("snack_found")


func give_snack():
	var given_snack = snack_arr.pop_front()
	self.emit_signal("snack_given")
	return given_snack


func signal_test():
	print("Achievement acknowledges signal.")






var num_of_cleaned_trash: int = 0
var is_dutiful_citizen: bool = false

func trash_cleaned():
	num_of_cleaned_trash += 1
	
	if num_of_cleaned_trash == 6:
		is_dutiful_citizen = true
		emit_signal("dutiful_citizen_fulfilled")







var is_woof_found: bool = false
var is_saucied_woof: bool = false
var is_club_door_unlocked: bool = false
var is_allow_wolf_in_mall: bool = false
var is_woof_encountered: bool = false
var is_woof_saucied: bool = false
var is_woof_and_koubold_encountered: bool = false
var is_seen_woof_by_window: bool = false


var is_koubold_found: bool = false
var is_saucied_koubold: bool = false




var is_meetup_quest_complete: bool = false
var is_scarf_found: bool = false
var is_scarf_given: bool = false

func koubold_found():
	is_koubold_found = true
	


func is_mox_meetup_ready() -> bool:
	if is_saucied_koubold and is_saucied_woof:
		return true
	return false


func start_koubold_and_wolf_miniquest():
	is_koubold_found = true
	is_seen_woof_by_window = true
	is_woof_and_koubold_encountered = true
	is_woof_encountered = true
	is_allow_wolf_in_mall = true
	is_club_door_unlocked = true

	is_saucied_koubold = true
	is_saucied_woof = true


func scarf_found():
	is_scarf_found = true
	emit_signal("scarf_found")


func complete_miniquest():
	is_scarf_given = true
	emit_signal("scarf_given")
	is_meetup_quest_complete = true






var is_newspaper_found: bool = false

func newspaper_found():
	is_newspaper_found = true
	emit_signal("newspaper_found")






var plants_cleared: int = 0
var is_plants_cleared: bool = false

func plant_cleared():
	plants_cleared += 1

	if plants_cleared == 30:
		achieved("janitor")
		is_plants_cleared = true

	self.emit_signal("plant_cleared")


func get_plants_cleared() -> int:
	return plants_cleared


func achieved(achievement_name):
	match achievement_name:
		"janitor": emit_signal("janitor_achieved")


func get_stats_string() -> String:
	var stats_string = ""\
	+ "   Plants cleared: " + str(Achievements.get_plants_cleared()) + "\n"\
	+ "   Cinema collected: " + str(Achievements.get_num_of_cinema_tapes()) + "\n"

	if Achievements.is_koubold_found:
		stats_string += "   Found koubold" + "\n"

	if Achievements.is_seen_woof_by_window:
		stats_string += "   Found woof" + "\n"

	if Achievements.is_dutiful_citizen:
		stats_string += "   Cleaned up trash bins" + "\n"

	if Achievements.is_plants_cleared:
		stats_string += "   Cleared plants" + "\n"

	if Achievements.is_meetup_quest_complete:
		stats_string += "   Met both koubold and woof" + "\n"

	if get_num_of_cinema_tapes() == 8:
		stats_string += "   Collected cinema" + "\n"

	return stats_string





func reset_achievements():
	reset_cinema()

	collected_tapes = []
	snack_arr = []
	is_koubold_found = false
	is_seen_woof_by_window = false
	is_dutiful_citizen = false
	is_plants_cleared = false
	is_meetup_quest_complete = false


	is_saucied_koubold = false
	is_saucied_woof = false


	is_koubold_found = false
	is_seen_woof_by_window = false
	is_woof_and_koubold_encountered = false
	is_woof_encountered = false
	is_allow_wolf_in_mall = false
	is_club_door_unlocked = false

	num_of_cleaned_trash = 0
	is_dutiful_citizen = false

	is_vending_machine_empty = false
	koubold_snack_given_arr = []

	plants_cleared = 0
	is_plants_cleared = false

func save():
	var save = {
		"collected_tapes": collected_tapes, 
		"is_vending_machine_empty": is_vending_machine_empty, 
		"snack_arr": snack_arr, 
		"koubold_snack_given_arr": koubold_snack_given_arr, 
		"is_dutiful_citizen": is_dutiful_citizen, 
		"is_woof_found": is_woof_found, 
		"is_saucied_woof": is_saucied_woof, 
		"is_club_door_unlocked": is_club_door_unlocked, 
		"is_allow_wolf_in_mall": is_allow_wolf_in_mall, 
		"is_woof_encountered": is_woof_encountered, 
		"is_woof_saucied": is_woof_saucied, 
		"is_woof_and_koubold_encountered": is_woof_and_koubold_encountered, 
		"is_seen_woof_by_window": is_seen_woof_by_window, 
		"is_koubold_found": is_koubold_found, 
		"is_saucied_koubold": is_saucied_koubold, 
		"is_meetup_quest_complete": is_meetup_quest_complete, 
		"is_scarf_found": is_scarf_found, 
		"is_scarf_given": is_scarf_given, 
		"is_newspaper_found": is_newspaper_found, 
		"plants_cleared": plants_cleared, 
		"is_plants_cleared": is_plants_cleared, 
	}
	return save
	

func load_data(data_dict):
	if data_dict == null: return
		
	for key in data_dict:
		set(key, data_dict[key])
