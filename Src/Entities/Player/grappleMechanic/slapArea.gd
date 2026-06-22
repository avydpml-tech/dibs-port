extends Area2D

export (NodePath)onready var minigame_player = get_node(minigame_player)

var knockback_force
var damage
var dont_decrease_stamina_cooldown: float = 0.2
var controller_weight_vec = Vector2(0, 0)

signal player_slapped


func _ready():
	knockback_force = get_parent().get_parent().knockback_force
	damage = get_parent().get_parent().damage
	$CollisionShape2D.disabled = true

	
	if not is_connected("player_slapped", Globals.get_player(), "decrease_stamina"):
		connect("player_slapped", Globals.get_player(), "decrease_stamina")


func _physics_process(delta):
	controller_weight_vec = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	
	if Globals.is_using_controller:
		var right_stick_dir = controller_weight_vec.angle()
		if right_stick_dir != 0:
			get_parent().rotation = right_stick_dir
	else:
		get_parent().look_at(get_global_mouse_position())


func _input(event):
	var mouse_pressed = event.is_action_pressed("ui_left_mouse")
	var anim_playing = $slapAnimPlayer.is_playing()

	if mouse_pressed and not anim_playing:
		slap()


func slap():
	if Achievements.is_meetup_quest_complete:
		$slapAnimPlayer.play("broom_slap")
	else:
		$slapAnimPlayer.play("slap")
	
	$swish.play()


func check_slap_area():
	var entity = minigame_player.minigame_manager.entity_inst
	print(entity)

	if entity == null:
		return


	if $justHitCreature.is_stopped() and not SettingsManager.is_bored_mode\
	and entity.entity_name != "f_wolf":
		emit_signal("player_slapped")
		

func _on_slapArea_body_entered(body):
	var tenticon_list = get_tree().get_nodes_in_group("Tenticons")
	var creature_heart = get_tree().get_nodes_in_group("CreatureHeart")

	if not (body in tenticon_list or body in creature_heart): return

	if body in tenticon_list:
		body.knockback(get_parent().global_position, knockback_force)
		$hit.play()
	elif body in creature_heart:
		body.damage(1) if not Achievements.is_meetup_quest_complete else body.damage(10)
	
	$justHitCreature.start(dont_decrease_stamina_cooldown)


func _on_slapAnimPlayer_animation_finished(anim_string):
	$CollisionShape2D.disabled = true
