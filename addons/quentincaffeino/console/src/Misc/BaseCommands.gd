
extends Reference



var _console



func _init(console):
	self._console = console

	self._console.add_command("echo", self._console, "write")\
	.set_description("Prints a string.")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("history", self._console.History, "print_all")\
	.set_description("Print all previous commands used during the session.")\
	.register()

	self._console.add_command("commands", self, "_list_commands")\
	.set_description("Lists all available commands.")\
	.register()

	self._console.add_command("help", self, "_help")\
	.set_description("Outputs usage instructions.")\
	.add_argument("command", TYPE_STRING)\
	.register()

	self._console.add_command("quit", self, "_quit")\
	.set_description("Exit application.")\
	.register()

	self._console.add_command("clear", self._console)\
	.set_description("Clear the terminal.")\
	.register()

	self._console.add_command("giveammo", self, "_give_ammo")\
	.set_description("Adds ammo. Accepts [1..3]. No argument gives full ammo.")\
	.add_argument("text", TYPE_INT)\
	.register()

	self._console.add_command("removeammo", self, "_remove_ammo")\
	.set_description("Removes ammo. Accepts [1..3]. No argument removes all ammo.")\
	.add_argument("int", TYPE_INT)\
	.register()

	self._console.add_command("health", self, "_add_clothes")\
	.set_description("Adds clothes. Accepts [1..3]. No argument gives full clothes.")\
	.add_argument("int", TYPE_INT)\
	.register()

	self._console.add_command("giveclothes", self, "_add_clothes")\
	.set_description("Adds clothes. Accepts [1..3]. No argument gives full clothes.")\
	.add_argument("int", TYPE_INT)\
	.register()

	self._console.add_command("removeclothes", self, "_remove_clothes")\
	.set_description("Removes clothes. Accepts [1..3]. No argument removes all clothes.")\
	.add_argument("int", TYPE_INT)\
	.register()

	self._console.add_command("givecircles", self, "_give_circles")\
	.set_description("Adds 'circles'. Accepts [1..3]. No argument gives full circles.")\
	.add_argument("int", TYPE_INT)\
	.register()

	
	self._console.add_command("clearcircles", self, "_clear_circles")\
	.set_description("Clears 'circles'. Accepts [1..3]. No argument clears all circles.")\
	.add_argument("int", TYPE_INT)\
	.register()

	self._console.add_command("resetenemies", self, "_reset_enemies")\
	.set_description("Resets enemies. Enemies respawn after exiting a room.")\
	.register()

	
	
	self._console.add_command("unlocktapes", self, "_unlock_tapes")\
	.set_description("Unlocks all cinema tapes.")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("resettapes", self, "_reset_tapes")\
	.set_description("Resets cinema tapes.")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("reseteverything", self, "_reset_everything")\
	.set_description("Resets everything. Warning: Can get stuck on some levels.")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("showkoubold", self, "_show_koubold")\
	.set_description("Shows koubold in diner. Walk out of the level and come back to see koubold.")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("showwoof", self, "_show_wolf")\
	.set_description("Shows woof in mainhub. Walk out of the level and come back to see woof.")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("startminiquest", self, "_start_miniquest")\
	.set_description("Starts koubold and wolf miniquest")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("givesnack", self, "_give_snack")\
	.set_description("Gives snack.")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("deletesettingsfile", self, "_delete_settings")\
	.set_description("Resets settings. Use this if you crash when in options/extras.")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("disableautosave", self, "_disable_autosave")\
	.set_description("Disables autosave. Can be used with 'reseteverything' to delete save too. Autosave is reenabled after quitting game.")\
	.add_argument("text", TYPE_STRING)\
	.register()

	self._console.add_command("enableautosave", self, "_enable_autosave")\
	.set_description("Enables autosave.")\
	.add_argument("text", TYPE_STRING)\
	.register()







func _help(command_name = null):
	if command_name:
		var command = self._console.get_command(command_name)

		if command:
			command.describe()
		else:
			self._console.Log.warn("No help for `" + command_name + "` command were found.")

	else:
		self._console.write_line(\
		"Type [color=#ffff66][url=help]help[/url] <command-name>[/color] show information about command.\n" + \
		"Type [color=#ffff66][url=commands]commands[/url][/color] to get a list of all commands.\n" + \
		"Type [color=#ffff66][url=quit]quit[/url][/color] to exit the application.")




func _list_commands():
	for command in self._console._command_service.values():
		var name = command.get_name()
		self._console.write_line("[color=#ffff66][url=%s]%s[/url][/color]" % [name, name])




func _quit():
	self._console.Log.warn("Quitting application...")
	self._console.get_tree().quit()




func _version():
	self._console.write_line(Engine.get_version_info())


func _give_ammo(ammo_arg = null):
	var p = Globals.get_player()
	var console_print = "Mox given " + str(ammo_arg) + " ammo."
	
	if ammo_arg == null:
		p.ammo_count = 9
		ammo_arg = 3
		console_print = "Mox given full ammo."
		
	for i in range(ammo_arg):
		p.add_mag(9)
		
	self._console.write_line(console_print)


func _give_circles(int_arg = null):
	var p = Globals.get_player()
	
	if int_arg == null:
		p._add_coom_count(3)
		self._console.write_line("Given full circles.")
	else:
		p._add_coom_count(int_arg)
		self._console.write_line("Given " + str(int_arg) + " circles.")


func _delete_settings():
	Globals.delete_settings()
	self._console.write_line("Settings file deleted.")


func _disable_autosave():
	SettingsManager.is_autosave = false
	self._console.write_line("Autosave disabled. Autosave will reenable after quitting game.")

func _enable_autosave():
	SettingsManager.is_autosave = true
	self._console.write_line("Autosave enabled.")
	


func _clear_circles(int_arg = null):
	var p = Globals.get_player()
	
	if int_arg == null:
		p._clear_coom_count()
		self._console.write_line("Cleared full circles.")
	else:
		p._clear_coom_count(int_arg)
		self._console.write_line("Cleared " + str(int_arg) + " circles.")


func _reset_enemies():
	EntityManager.reset_entities_list()
	self._console.write_line("Enemies reset. Does not reset achievements.")
	


func _reset_everything():
	Globals.reset_everything()
	self._console.write_line("Everything reset. Warning: Probably stuck in some levels.")


func _show_koubold():
	Achievements.is_vending_machine_empty = true
	Achievements.is_club_door_unlocked = true
	self._console.write_line("Koubs now in diner. Exit room and come back to diner to spawn.")


func _show_wolf():
	Achievements.is_allow_wolf_in_mall = true
	Achievements.is_woof_encountered = true
	Achievements.is_woof_found = true
	self._console.write_line("Woof now in mainhub. Exit room and come back to mainhub to spawn.")


func _give_snack():
	Achievements.snack_found()


func _add_clothes(health_arg = null):
	var p = Globals.get_player()
	
	if health_arg == null:
		p._add_health(3)
		self._console.write_line("Mox given full clothes.")
	else:
		p._add_health(health_arg)
		self._console.write_line("Mox given " + str(health_arg) + " clothes.")


func _remove_clothes(health_arg = null):
	var player = Globals.get_player()
	
	if health_arg == null:
		player._remove_clothes(3)
		self._console.write_line("Removed clothes. Bye.")
	else:
		player._remove_clothes(health_arg)
		self._console.write_line("Removed " + str(health_arg) + " clothes.")


func _remove_ammo(value = null):
	
	if value == null:
		Globals.get_player().pop_front_mags(value)
		self._console.write_line("Removed ammo. Bye.")
	
	
	else:
		Globals.get_player().pop_front_mags(value)
		self._console.write_line("Removed " + str(value) + " ammo.")


func _unlock_tapes():
	Achievements.auto_complete_cinema()
	self._console.write_line("Cinema gallery unlocked. Congrats.")


func _reset_tapes():
	Achievements.reset_cinema()
	self._console.write_line("Cinema gallery reset. Collected tapes back in starting positions.")


func _start_miniquest():
	Achievements.start_koubold_and_wolf_miniquest()


	
	
	
	
