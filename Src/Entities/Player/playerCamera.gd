extends Camera2D



var default_camera_zoom: float = 0
var easing_zoom: float = 1; var easing_pan: float = 1

onready var parent = get_parent()
onready var vignette = get_node("../visualNodes/playerVignette")
onready var pause_vignette = get_node("../visualNodes/playerPauseVignette")
onready var pause_vignette_anim = get_node("../visualNodes/playerPauseVignette/AnimationPlayer")
onready var pause_light = get_node("../visualNodes/playerPauseLight")
onready var pause_light_anim = get_node("../visualNodes/playerPauseLight/AnimationPlayer")





signal camera_zoomed()

func _ready():
	
	if parent.connect("player_state_changed", self, "player_state_changed") != OK:
		print("ERROR: ", self, ": signal player_state_changed not connected to ", 
								"player_state_changed.")

	if connect("camera_zoomed", self, "_on_camera_zoomed") != OK:
		print("ERROR: ", self, ": signal camera_zoomed not connected to _on_camera_zoomed")

	if Pause.connect("game_paused", self, "_on_camera_zoomed") != OK:
		print("ERROR: ", self, ": signal game_paused not connected to _on_camera_zoomed")

	if Pause.connect("game_unpaused", self, "_on_camera_zoomed") != OK:
		print("ERROR: ", self, ": signal game_paused not connected to _on_camera_zoomed")

	position = Vector2(0, - 50)
	default_camera_zoom = parent.default_camera_zoom
	default_camera_saucy_zoom = parent.camera_saucy_zoom
	camera_saucy_zoom = default_camera_saucy_zoom
	add_crosshair()

	
func _process(_delta):
	cameraFunctions()
	$cursorPos.global_position = get_global_mouse_position()
	

func add_crosshair():
	var canva = parent.get_node("CrosshairCanvasLayer")
	var scene_inst = load("res://Src/Entities/Player/playerUI/playerReticle.tscn").instance()
	
	canva.call_deferred("add_child", scene_inst)
	scene_inst.set_pause_mode(Node.PAUSE_MODE_PROCESS)
	scene_inst.disable_collision = true
	
	
func player_state_changed():
	offset_grappled()


func cameraFunctions():
	vignette_follow()
	vignette_pause_pos()

	
	if parent.player_state == "saucied":
		saucy_time_zoom()
	else:
		paused_zoom()
	
	
	if parent.player_state == "tangled":
		gallery_cam()
	elif parent.player_state == "aim":
		telescope_cam()
		
	elif parent.current_health > 0 and \
	parent.flashlight_active and \
	not parent.player_state in ["grappled", "tangled", "saucied", "afterglow", "sit"]:
			gameplay_panning()
	else:
		camera_pan(0, 0.1)

	
func vignette_follow():
	vignette.position = position

func vignette_pause_pos():
	pause_vignette.position = position
	
func gameplay_panning():
	if parent.dir == "right": camera_pan(120, 0.06)
	if parent.dir == "left": camera_pan( - 120, 0.06)

func telescope_cam():
	
	
	if parent.player_state == "aim" and not_grappled():
		camera_zoom(0.7, 0.1)

		
		
		
		
		
		if Globals.is_using_controller:
			if parent.dir == "right": camera_pan(280, 0.06)
			if parent.dir == "left": camera_pan( - 280, 0.06)
		else:
			if parent.dir == "right": camera_pan(280, 0.07)
			if parent.dir == "left": camera_pan( - 280, 0.07)
	else: camera_pan(0, 0.1)

func not_grappled() -> bool:
	if parent.player_state == "grappled": return false
	if parent.player_state == "saucied": return false
	return true

var camera_saucy_zoom: float = 0
var default_camera_saucy_zoom: float = 0

func saucy_time_zoom():
	
	
	var SHIFT = Input.is_action_pressed("ui_shift")
	if Input.is_action_pressed("ui_up") and SHIFT:
		camera_saucy_zoom -= 0.01
	if Input.is_action_pressed("ui_down") and SHIFT:
		camera_saucy_zoom += 0.01

	
	camera_saucy_zoom = clamp(camera_saucy_zoom, 0.5, default_camera_saucy_zoom)

	
	camera_zoom(camera_saucy_zoom, 0.1)

func gallery_cam():
	camera_pan(250, 0.2)
	

func paused_zoom():
	var is_paused = get_tree().paused
	match is_paused:
		true:
			camera_zoom(0.6, 0.1)
			pause_light.visible = true

		false:
			camera_zoom(default_camera_zoom, 0.1)
			pause_light.visible = false

\
\
\
\
\
\
\
"\r\nNote: The equation below will infinitely get closer to its target\r\nand will never actually reach it, so you might as well\r\nsnap it to its target once it reaches a certain point to save\r\nprocessing power.\r\n\r\nBUG: when activating camera_zoom, it will only zoom a little bit.\r\n"

func camera_zoom( var target: float, var zoom_speed: float):
	easing_zoom += (target - easing_zoom) * zoom_speed
	zoom = Vector2(easing_zoom, easing_zoom)

	
func camera_pan( var target: float, var pan_speed: float):
	easing_pan += (target - easing_pan) * pan_speed
	position = Vector2(easing_pan, - 50)
	
	
func _on_camera_zoomed():
	if get_tree().paused:
		pause_vignette_anim.play("stronger_vignette_fade")
		pause_light_anim.play("stronger_vignette_fade")
	else:
		pause_vignette_anim.play_backwards("stronger_vignette_fade")
		pause_light_anim.play_backwards("stronger_vignette_fade")




onready var camera_anim_player = get_node("cameraAnimationPlayer")


func offset_grappled():
	if parent.player_state == "grappled":
		if not camera_anim_player.is_playing():
			camera_anim_player.play("grappled")

func offset_shooting():
	var dir = Vector2(5, 0) if parent.dir == "right" else Vector2( - 5, 0)

	
	AnimationManager.add_keyframe(camera_anim_player, "shoot", 
									0.2, dir)
	camera_anim_player.play("shoot")
