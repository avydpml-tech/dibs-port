extends KinematicBody2D

signal boss_reading_entered
signal boss_reading_exited
signal newspaper_swat_flashed
signal door_closed
signal state_changed(state)

export (int) var boss_health: int = 40 setget set_boss_health
export (int) var max_annoy_count: int = 8
export (Resource) var ammo_scene = null
export (NodePath)onready var BossAnimPlayer = get_node(BossAnimPlayer) as AnimationPlayer
export (NodePath)onready var start_sweep_point = get_node(start_sweep_point) as Position2D
export (NodePath)onready var end_sweep_point = get_node(end_sweep_point) as Position2D

var attack_arr = [
	"play_floor_sweep", 
	"play_newspaper_swat", 
	"play_roof_ammo", 
	]
var current_state: String = ""
var annoy_counter: int = 0 setget set_annoy_counter
var is_boss_fight: bool = false
var is_met_first_time: bool = false
var is_broom_given: bool = false



var attack_repeated_counter: int = 0
var last_attack: String = ""
var max_boss_health: int = boss_health


onready var smp = $StateMachinePlayer


func _ready():
	add_to_group("CanBeShot")
	add_to_group("CanBeFlashed")
	update_text()

	smp.connect("updated", self, "_on_StateMachinePlayer_updated")
	Globals.get_player().connect("player_grappled", self, "set_is_grappled")
	Globals.get_player().connect("player_grapple_freed", self, "set_is_grappled")
	Globals.get_player().connect("player_tenta_grapple", self, "bonk_mox")

func _input(event):
	
	if event.is_action_pressed("ui_F9"):
		emit_trigger("given_broom")
		






var is_started_boss_fight: bool = false
var is_blocked: bool = false
var is_player_grappled: bool = false
var is_player_lost: bool = false

const StateDirectory = preload("res://addons/imjp94.yafsm/src/StateDirectory.gd")


func _on_StateMachinePlayer_transited(from_state, to_state):
	update_boss_state_text(to_state)

	
	match to_state:
		
		"Mox_Hug", \
		"Given_Broom", \
		"Surprised_Done", \
		"Surprised":
			play_attack_animation(to_state)
		
		"Reading":
			play_attack_animation(to_state)
			emit_signal("boss_reading_entered")

		"Reading_Flashed":
			if Globals.get_player().global_position > global_position:
				play_attack_animation("Reading_Flashed_Right")
			else:
				play_attack_animation("Reading_Flashed_Left")

		"Tired_Boss":
			play_attack_animation(to_state)
			$AnimationPlayer.set_speed_scale(0.9)


		"BSD_/Boss_Start":
			if not is_started_boss_fight:
				print("OI WHYD YOU HIT ME")
				play_attack_animation(to_state)

		
		"BSD_/Fight_Idle":
			play_attack_animation(to_state)
			start_attack_timer()
			$PhysicBodies / BossTentaStatic2.global_position.y += 300
			is_boss_fight = true

		"BSD_/Newspaper_Swat_Slam":
			$PhysicBodies / BossTentaStatic2.global_position = Globals.get_player().global_position

		
		"BSD_/Newspaper_Swat_Expose", \
		"BSD_/Newspaper_Swat_Slam", \
		"BSD_/Newspaper_Swat_Ready", \
		"BSD_/Roof_Ammo", \
		"BSD_/Roof_Ammo_Hit", \
		"BSD_/Fight_Idle_Block":
			play_attack_animation(to_state)
			$Sprites / BossSprite.flip_h = Globals.get_player().global_position < global_position

		"BSD_/Player_Lifted":
			play_attack_animation(to_state)
			$Sprites / BossSprite.flip_h = false

		"BSD_/Floor_Sweep":
			play_attack_animation(to_state)
			$Sprites / BossSprite.flip_h = Globals.get_player().global_position < global_position

			var sweep_collision = Vector2(0, 0)
			if Globals.get_player().global_position > global_position:
				sweep_collision.x = 201.066
			else:
				sweep_collision.x = - 201.066
				
			$PhysicBodies / floorSweepCollide / CollisionShape2D.position.x = sweep_collision.x

		"BSD_/Newspaper_Swat_Flashed":
			play_attack_animation(to_state)
			emit_signal("newspaper_swat_flashed")
			
			var sweep_collision = Vector2(0, 0)
			if Globals.get_player().global_position > global_position:
				sweep_collision.x = 201.066
			else:
				sweep_collision.x = - 201.066
				
			$PhysicBodies / floorSweepCollide / CollisionShape2D.position.x = sweep_collision.x


		"BSD_/Player_Lose":
			play_attack_animation(to_state)
			is_boss_fight = false

		
		"BHM_/Idle":
			print(";klsjadfkl;jweoiru")

		"BHM_/Exit":
			print("saldfjka;sldkfjaklsfj")

		
		"BSD_/Death":
			print("kinda dead now")
			play_attack_animation(to_state)
			$hitPlayer.play("death")
			is_boss_fight = false
			
		"BSD_/Floor_Sweep":
			play_attack_animation(to_state)

		"End":
			play_attack_animation(to_state)
			is_boss_fight = false
			

	
	match from_state:
		"Reading":
			emit_signal("boss_reading_exited")

		"BSD_/Death":
			queue_free()

		"BSD_/Player_Lose":
			is_player_lost = false
			reset_boss()

		"BSD_/Floor_Sweep":
			$PhysicBodies / floorSweepCollide / CollisionShape2D.disabled = true

		"BSD_/Newspaper_Swat_Flashed":
			$PhysicBodies / floorSweepCollide / CollisionShape2D.disabled = true

		"Given_Broom":
			emit_signal("boss_reading_exited")
			is_broom_given = true

	emit_signal("state_changed", to_state)


func reset_boss():
	get_owner().newspaper_swat_count = 0
	boss_health = max_boss_health
	annoy_counter = 0
	update_text()



func _on_StateMachinePlayer_updated(state, delta):
	set_StateMachinePlayer_parameters()
	match state:
		"BSD_/Newspaper_Swat_Ready", \
		"BSD_/Boss_Start", \
		"BSD_/Fight_Idle_Block", \
		"BSD_/Fight_Idle":
			is_blocked = true
			
			return

		"BSD/_Roof_Ammo":
			is_blocked = false

		"BSD_/Player_Lifted":
			Globals.get_player().global_position = $PhysicBodies / disabledPlayerPos.global_position
			is_blocked = false

		"BSD_/Player_Lose":
			Globals.get_player().global_position = $PhysicBodies / disabledPlayerPos.global_position
			Globals.get_player().should_fall_when_grappled = false
			$Visual / ScruffMoxTest.global_position = $PhysicBodies / disabledPlayerPos.global_position
			is_blocked = false

		_:
			is_blocked = false


func set_StateMachinePlayer_parameters():
	smp.set_param("annoy_counter", annoy_counter)
	smp.set_param("flashed_once", flashed_once)
	smp.set_param("boss_health", boss_health)
	smp.set_param("is_player_grappled", is_player_grappled)
	smp.set_param("is_player_lost", is_player_lost)
	smp.set_param("is_in_playable_area", is_in_playable_area)
	smp.set_param("is_tired_boss", Globals.is_tired_boss)
	smp.set_param("newspaper_swat_count", get_owner().newspaper_swat_count)


func emit_trigger(anim_name: String):
	smp.set_trigger(anim_name)


func player_lost():
	is_player_lost = true
	emit_trigger("Interrupt")





func play_attack_animation(state_name):
	var stripped_str = state_name.replace("/", "")
	$AnimationPlayer.play(stripped_str)


func turn_player_right():
	Globals.get_player().dir = "right"



func choose_random_attack():
	if attack_arr.empty():
		return
	
	var random_attack = attack_arr[randi() % attack_arr.size()]

	
	if attack_repeated_counter >= 1 and last_attack == random_attack:
		for new_attack in attack_arr:
			if random_attack != new_attack:
				random_attack = new_attack
				attack_repeated_counter = 0

	
	elif last_attack == random_attack and last_attack == "play_roof_ammo":
		for new_attack in attack_arr:
			if random_attack != new_attack:
				random_attack = new_attack
				attack_repeated_counter = 0


	if last_attack == random_attack:
		attack_repeated_counter += 1
	else:
		attack_repeated_counter = 0

	
	
	last_attack = random_attack
	emit_trigger(random_attack)


func _on_attackTimer_timeout():
	choose_random_attack()


func start_attack_timer():
	$Timers / attackTimer.start()


func start_floor_sweep():
	for i in get_tree().get_nodes_in_group("floor_sweep"):
		
		if Globals.get_player().global_position > global_position:
			i.start_sweep(global_position, end_sweep_point.global_position)
		else:
			i.start_sweep(global_position, start_sweep_point.global_position)


func enable_floor_sweep_collision():
	$PhysicBodies / floorSweepCollide / CollisionShape2D.disabled = false




func _on_AnimationPlayerOld_animation_finished(anim_name: String):
	emit_trigger("anim_finished")


func _on_AnimationPlayer_animation_finished(anim_name: String):
	emit_trigger("anim_finished")





func set_boss_health(value):
	boss_health = value
	if boss_health <= 0:
		emit_trigger("Interrupt")


func set_annoy_counter(value):
	annoy_counter = value

	if annoy_counter >= max_annoy_count:
		emit_trigger("boss_fight_started")





var is_in_playable_area: bool = false
func shot(_dmg):
	$hitPlayer.stop()

	if is_blocked or not is_in_playable_area:
		$hitPlayer.play("blocked")
	else:
		emit_trigger("is_hit")
		$hitPlayer.play("hit")
		self.boss_health -= 1
		self.annoy_counter += 1

	update_text()


func close_boss_doors():
	for i in get_tree().get_nodes_in_group("boss_door"):
		self.connect("door_closed", i, "_interacted")
	emit_signal("door_closed")










func bonk_mox():
	get_owner().newspaper_swat_count += 1


func spawn_ammo():
	var ammo_inst = ammo_scene.instance()
	ammo_inst.is_temporary = true
	
	get_owner().add_child(ammo_inst, true)
	ammo_inst.set_owner(get_owner())

	var ammo_pos = get_owner().get_node("AmmoPlacementPos").global_position

	ammo_inst.global_position.y = ammo_pos.y
	ammo_inst.global_position.x = - (randi() % 300) + (randi() % 300)


func update_text():
	var stats = "Annoy Count: " + str(annoy_counter)\
	+ "\nBoss Health: " + str(boss_health)
	$Visual / labels / AnnoyCounter.text = stats


func update_boss_state_text(to_state):
	var remove_annoying_prefix
	remove_annoying_prefix = to_state.substr(4, - 1) if to_state.substr(0, 3) in ["BSD", "BHM"] else to_state
	$Visual / labels / BossState.text = remove_annoying_prefix.replace("/", "")
	current_state = remove_annoying_prefix


var flashed_once: bool = false
func flashed_by_flashlight():
	
	if not is_met_first_time:
		emit_trigger("first_approached")
	else:
		emit_trigger("boss_flashed")

	if not flashed_once:
		flashed_once = true


func not_flashed_anymore():
	emit_trigger("boss_not_flashed")
	if flashed_once:
		flashed_once = false


func set_is_grappled():
	is_player_grappled = not is_player_grappled
	if is_player_grappled:
		emit_trigger("Interrupt")
	else:
		emit_trigger("freed_grapple")


func _enable_mox():
	Globals.get_player().enable_mox()






func _on_SurprisedTimer_timeout():
	emit_trigger("surprise_timeout")


func _on_playableArea_body_entered(body):
	if body == Globals.get_player():
		is_in_playable_area = true
		if is_boss_fight:
			$CanvasLayer / Label.hide()


func _on_playableArea_body_exited(body):
	if body == Globals.get_player():
		is_in_playable_area = false
		if is_boss_fight:
			$CanvasLayer / Label.show()
			emit_trigger("Interrupt")
			emit_trigger("boss_block")



func _on_realPlayableArea_body_entered(body: Node):
	if body == Globals.get_player():
		is_in_playable_area = true
		if is_boss_fight:
			$CanvasLayer / Label.hide()
			emit_trigger("boss_unblock")


func _on_PlayerEnteredAreaSurprise_body_entered(body):
	
	if body.is_in_group("Player"):
		if not is_met_first_time:
			$Timers / SurprisedTimer.start()
			is_met_first_time = true
			emit_trigger("first_approached")
			


func _on_MiddlePlayerDetect_body_exited(body: Node):
	if body.is_in_group("Player"):
		left_and_right_surprised_anims(body)


var dir_cache: bool = true
func left_and_right_surprised_anims(body):
	var anim_direction = body.global_position > global_position

	
	if ( not current_state == "Surprised"\
	or dir_cache == anim_direction)\
	or $Timers / SurprisedTimer.is_stopped():
		return

	dir_cache = anim_direction

	if anim_direction:
		play_attack_animation("Surprised_Right")
	else:
		play_attack_animation("Surprised_Left")

























