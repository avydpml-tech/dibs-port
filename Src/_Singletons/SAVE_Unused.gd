







extends Node


onready var player = get_tree().get_root().find_node("Player", true, false)
onready var head = get_tree().get_root().find_node("Head", true, false)
onready var weapon = get_tree().get_root().find_node("ShootRayCast", true, false)

var path = "user://save.dat"
var file = File.new()
var menu = VBoxContainer.new()

var can_use = true

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	
	add_child(menu)
	
	if file.file_exists(path):
		load_game()

func _input(event):
	if can_use:
		if Input.is_key_pressed(KEY_F5):
			save_game()
			can_use = false
			yield(get_tree().create_timer(0.5), "timeout")
			can_use = true
			
		if Input.is_key_pressed(KEY_F6):
			load_game()
			can_use = false
			yield(get_tree().create_timer(0.5), "timeout")
			can_use = true

func save_game():
	file.open(path, File.WRITE)
	
	
	file.store_line(to_json({"transform": var2str(player.transform), "head_rotation": head.rotation.x, "ammo": weapon.ammo}))
	file.close()
	
	display_info("> game saved")

func load_game():
	file.open(path, File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	
	
	player.transform = str2var(data["transform"])
	head.rotation.x = data["head_rotation"]
	weapon.ammo = data["ammo"]
	
	display_info("> game loaded")
	
	return data

func display_info(message):
	var label = Label.new()
	label.text = message
	label.set("custom_colors/font_color", Color(0, 1, 0))
	menu.add_child(label)
	yield(get_tree().create_timer(3.0), "timeout")
	label.queue_free()