extends StateMachine






onready var label = $debugLabel
var grapple_timer = Timer.new()
var reload_conditions



func _ready():
	
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("disabled")

	
	add_state("sit")
	
	
	add_state("aim")
	add_state("reload")
	
	
	add_state("grappled")
	add_state("saucied")
	add_state("afterglow")
	add_state("tangled")

	call_deferred("set_state", states.idle)
	
	add_child(grapple_timer)
	grapple_timer.one_shot = true
	
	

	parent.connect("set_grapple_state", self, "set_to_grapple_state")
	parent.connect("set_idle_state", self, "set_to_idle_state")
	parent.connect("set_state", self, "set_currect_state")


func set_to_grapple_state():
	call_deferred("set_state", states.grappled)

func set_to_idle_state():
	call_deferred("set_state", states.idle)



func set_currect_state(state_key):
	call_deferred("set_state", states.get(state_key))
	print(states.get(state_key))


func _state_logic(delta):
	parent._apply_gravity(delta)
	parent._update_stamina(delta)
	show_state()
	if [states.disabled].has(state):
		parent.velocity.x = 0
		parent.flashlight(false)
	else:
		parent.flashlight(true)

	if parent.should_fall_when_grappled:
		parent._apply_movement()

	if [states.reload].has(state):
		parent._player_aim(false)
	else:
		parent._pistol_sounds("stop")
	
	if [states.tangled].has(state):
		parent.tangle_anim()

	
	if [states.aim].has(state):
		parent._player_aim(true)
		parent.random_bullet_spread = 0
		parent.flashlight_aim(parent.flashlight_active)
		parent._check_flashlight_area2D()
	else:
		parent.flashlight_aim(false)
		parent._check_suit_area2D()
		parent.random_bullet_spread = rand_range( - 3, 3)

	
	
	if not [states.aim, states.reload, states.grappled, 
			states.saucied, states.afterglow, 
			states.tangled, states.sit].has(state):
		parent._player_aim(false)
		parent._handle_move_input()
		parent._should_heal()
	else:
		parent.velocity.x = 0
	
	if not state in [states.afterglow, states.tangled, states.sit]:
		parent.dir_manager()
	else:
		parent.setDir("right")






func _get_transition(_delta):
	
	
	
	
	
	

	reload_conditions = Input.is_action_just_pressed("ui_r")\
	and parent.magazine_arr.size() > 0\
	and parent.ammo_count < parent.max_ammo_count

	match state:
		states.idle:
			
			var is_kb_okay = (Input.is_action_pressed("kb_left") or Input.is_action_pressed("kb_right"))\
			and not (Input.is_action_pressed("kb_left") and Input.is_action_pressed("kb_right"))
			var is_joy_okay = (Input.is_action_pressed("joy_left") or Input.is_action_pressed("joy_right"))

			if parent.is_tangled: return states.tangled
			if parent.is_afterglow: return states.afterglow
			if not parent.check_floor():
				if parent.velocity.y < 0: return states.jump
				elif parent.velocity.y > 0: return states.fall

			elif parent._check_if_player_grappled():
				return states.grappled
				
			elif parent.check_floor():
				if parent._should_aim(): return states.aim
				elif reload_conditions: return states.reload
				elif parent.should_move: return states.run

				
				
				elif is_kb_okay or is_joy_okay or parent.one_handed_movement:
					return states.run
			
			if parent.is_saucied_with_koubold or parent.is_auto_saucy:
				return states.saucied
			

			if parent.is_seated:
				return states.sit


		states.run:
			var is_kb_okay = not (Input.is_action_pressed("kb_left") or Input.is_action_pressed("kb_right"))\
			or (Input.is_action_pressed("kb_left") and Input.is_action_pressed("kb_right"))
			var is_joy_okay = not (Input.is_action_pressed("joy_left") or Input.is_action_pressed("joy_right"))

			
			if not parent.is_on_floor():
				if parent.velocity.y < 0: return states.jump
				elif parent.velocity.y > 0: return states.fall

			
			
			
			
			elif (is_kb_okay and is_joy_okay and not parent.one_handed_movement):
				return states.idle

			
			elif parent._check_if_player_grappled():
				return states.grappled
			
			
			elif parent._should_aim():
				return states.idle
			if reload_conditions:
				return states.reload

			
			if Input.is_action_just_pressed("ui_h"):
				return states.idle
			
			
			if parent.is_seated:
				return states.sit
				
		states.jump:
			if parent._check_if_player_grappled():
				return states.grappled
	
			if parent.is_on_floor(): return states.idle
			elif parent.velocity.y >= 0: return states.fall

		states.fall:
			if parent._check_if_player_grappled():
				return states.grappled
			elif parent.is_on_floor():
				if abs(parent.velocity.x) > 0:
					return states.run
				else:
					return states.idle
			elif parent.check_floor():
				if parent._should_aim(): return states.aim
				elif reload_conditions: return states.reload
			elif parent.velocity.y < 0: return states.jump
			
			
		states.aim:
			
			
			if parent.is_on_floor() and not parent._should_aim():
				return states.idle
			elif parent._check_if_player_grappled():
				return states.grappled
			elif Input.is_action_just_pressed("ui_r") and parent.magazine_arr.size() > 0:
				return states.reload
		
				
		states.reload:
			if parent._check_if_player_grappled():
				return states.grappled
			elif parent.reload_timer.is_stopped():
				return states.idle
			elif Input.is_action_just_pressed("ui_right_mouse"):
				return states.idle
			elif Input.is_action_just_pressed("ui_right")\
			or Input.is_action_just_pressed("ui_left"):
				return states.idle
			elif parent.return_to_idle:
				return states.idle
				
			
				
			
				
		states.grappled:
			
			
				
			if parent._is_player_still_grappled():
				return states.saucied

		states.saucied:
			if parent._is_saucy_animation_done():
				return states.idle
		
		states.afterglow:
			
			if not parent.anim_state_machine.is_playing():
				return states.idle
		
		states.tangled:
			if parent.tangle_counter >= parent.tangle_max:
				parent.is_tangled = false
				parent.coom_count = 0
				return states.idle
			if not parent.is_tangled:
				return states.idle
			if parent._check_if_player_grappled():
				return states.grappled
			elif parent._is_player_still_grappled():
				return states.saucied
		
		states.sit:
			if not parent.is_seated and not parent.is_player_input_disabled:
				return states.idle
			

	return null
	
			
func _enter_state(new_state, old_state):
	parent.player_clothes()
	parent.anim_state_machine.travel("idle")
	Globals.set_global_player_variables(parent.save_to_globals())
	
	if not new_state == states.fall:
		parent.player_ui.hide_player_stuck_label()
		parent.get_node("playerStuckTimer").stop()


	match new_state:
		states.idle:
			

			parent.return_to_idle = false
			parent._stop_saucy()
			parent._saucy_vignette("light")
			parent.get_node("staminaTimer").start(parent.stamina_recover_time)
			parent.player_sprite.visible = true
			parent.player_tangle_sprite.visible = false
			parent.check_blaster_light_state()

			parent.player_ui.stamina_just_reached_zero = false
			
			if not MenuHandler.is_current_menu(MenuHandler.MENU_LEVEL.TAB):
				parent.anim_state_machine.travel("idle")
			else:
				parent.anim_state_machine.travel("phone")

			parent.start_idle_timer()


		states.run:
			
			parent.stamina_rate = 5
			parent.anim_state_machine.travel("run")

			
			
			
			


			pass
		states.jump:
			
			parent.stamina_rate = 5
			parent.anim_state_machine.travel("jump")

			
			pass
		states.fall:
			
			parent.stamina_rate = 5
			parent.anim_state_machine.travel("fall")
			parent.get_node("playerStuckTimer").start()
		
		states.aim:
			parent.dir_to_cursor_pos()
			parent._pistol_sounds("up")
			parent.bullet_spread_timer.start()
			parent.anim_state_machine.travel("aim")

		states.reload:
			parent.start_reload_timer()

			parent._pistol_sounds("reload")
			parent.anim_state_machine.travel("reload")
			
		states.grappled:
			parent.stamina_rate = 5
			grapple_timer.start(5)
			parent._saucy_vignette("light_dark")
			parent.voice.play()
			
			parent.anim_state_machine.travel("idle")
			
			parent._start_grapple_mechanic()
			
		
		states.saucied:
			parent.stamina_rate = 5
			
			parent.being_saucied = true
			parent.should_move = false
			grapple_timer.start(7)
			parent.show_saucy_sprite(true)
			parent.saucy_sprite_anim.play()
			parent.start_pump_timer()
			parent._saucy_vignette("dark_light")
			
		states.afterglow:
			parent.stamina_rate = 5
			parent.setDir("right")
			parent.face_dir()
			parent.anim_state_machine.travel("afterglow")

		states.tangled:
			
			
			parent.is_afterglow = false
			parent.player_sprite.visible = false
			parent.player_tangle_anim.play("wake_up")
			parent.player_tangle_sprite.visible = true
			
			
			
			
			
			
			parent.stamina = 100

		states.sit:
			parent.anim_state_machine.travel("sit")
			parent.temp_flashlight = parent.flashlight_active
			parent.flashlight_active = false
		
		states.disabled:
			parent.temp_flashlight = parent.flashlight_active
			parent.flashlight_active = false
			parent.get_node("playerSprite").visible = false
	
	parent.player_state = states.keys()[state]


func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			parent.stop_idle_timer()
			parent.disable_phone_idle_mox()

		states.fall:
			parent._land_sound()
		states.aim:
			parent._pistol_sounds("down")
			parent.bullet_spread_timer.stop()
			parent.stopped_flashing_light()
		
		states.reload:
			if parent.reload_timer_in_threshold():
				parent._reload()
			
		
		
		states.grappled:
			if not parent.is_woof_or_koubold:
				parent.disable_saucy_timer.start(parent.disable_saucy_sec)
			parent._saucy_vignette("dark_light")
			parent.show_grapple_sprite(false)

		states.saucied:
			parent.disable_saucy_timer.start(parent.disable_saucy_sec)
			
			parent._stop_saucy()
			parent._saucy_vignette("dark_light")

			parent.is_tangled = false
			parent.player_sprite.visible = true

			if parent.coom_count >= parent.coom_capacity:
				parent.start_afterglow()

		states.tangled:
			parent.player_sprite.visible = true
			parent.player_tangle_sprite.visible = false
			parent.update_coom_circles()

		states.sit:
			parent.flashlight_active = parent.temp_flashlight
	
		states.disabled:
			parent.flashlight_active = parent.temp_flashlight
			parent.get_node("playerSprite").visible = true
			parent.is_seated = false
	
	



	
func show_state():
	if parent.show_debug:
		var strang = str(states.keys()[state])
		label.set_text(strang)