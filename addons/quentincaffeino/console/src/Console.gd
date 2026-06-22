
extends CanvasLayer

const BaseCommands = preload("Misc/BaseCommands.gd")
const DefaultActions = preload("../DefaultActions.gd")
const CommandService = preload("Command/CommandService.gd")


const IntRangeType = preload("Type/IntRangeType.gd")
const FloatRangeType = preload("Type/FloatRangeType.gd")
const FilterType = preload("Type/FilterType.gd")




signal toggled(is_console_shown)



signal command_added(name, target, target_name)

signal command_removed(name)

signal command_executed(command)

signal command_not_found(name)


var History = preload("Misc/History.gd").new(100) setget _set_readonly


var Log = preload("Misc/Logger.gd").new() setget _set_readonly


var _command_service



var _erase_bb_tags_regex


var is_console_shown = true setget _set_readonly


var consume_input = true


var previous_focus_owner = null



onready var _console_box = $ConsoleBox
onready var Text = $ConsoleBox / Container / ConsoleText setget _set_readonly
onready var Line = $ConsoleBox / Container / ConsoleLine setget _set_readonly
onready var _animation_player = $ConsoleBox / AnimationPlayer


func _init():
	self._command_service = CommandService.new(self)
	
	self._erase_bb_tags_regex = RegEx.new()
	self._erase_bb_tags_regex.compile("\\[[\\/]?[a-z0-9\\=\\#\\ \\_\\-\\,\\.\\;]+\\]")


func _ready():
	
	self.Text.set_selection_enabled(true)
	
	self.Text.set_scroll_follow(true)
	
	self.Text.connect("meta_clicked", self.Line, "set_text")

	
	self._console_box.hide()
	self._animation_player.connect("animation_finished", self, "_toggle_animation_finished")
	self.toggle_console()

	
	set_process_input(true)

	
	
	self.write_line(\
	ProjectSettings.get_setting("application/config/name") + \
	"\nType [color=#ffff66][url=help]help[/url][/color] to get more information about usage")

	
	self.BaseCommands.new(self)



func _input(e):
	if Input.is_action_just_pressed(DefaultActions.CONSOLE_TOGGLE):
		get_tree().paused = not get_tree().paused
		self.toggle_console()

	if (e.is_action_pressed("ui_cancel")) and is_console_shown:
		Pause.set_pause()
		self.toggle_console()




func get_command_service():
	return self._command_service




func get_command(name):
	return self._command_service.get(name)



func find_commands(name):
	return self._command_service.find(name)












func add_command(name, target, target_name = null):
	emit_signal("command_added", name, target, target_name)
	return self._command_service.create(name, target, target_name)



func remove_command(name):
	emit_signal("command_removed", name)
	return self._command_service.remove(name)




func write(message):
	message = str(message)
	if self.Text:
		self.Text.set_bbcode(self.Text.get_bbcode() + message)
	print(self._erase_bb_tags_regex.sub(message, "", true))



func write_line(message = ""):
	message = str(message)
	if self.Text:
		self.Text.set_bbcode(self.Text.get_bbcode() + message + "\n")
	print(self._erase_bb_tags_regex.sub(message, "", true))



func clear():
	if self.Text:
		self.Text.set_bbcode("")



func toggle_console():
	
	if not self.is_console_shown:
		previous_focus_owner = self.Line.get_focus_owner()
		self._console_box.show()
		self.Line.clear()
		self.Line.grab_focus()
		self._animation_player.play_backwards("fade")
	else:
		self.Line.accept_event()
		if is_instance_valid(previous_focus_owner):
			previous_focus_owner.grab_focus()
		previous_focus_owner = null
		self._animation_player.play("fade")

	is_console_shown = not self.is_console_shown
	emit_signal("toggled", is_console_shown)

	return self



func _toggle_animation_finished(animation):
	if not self.is_console_shown:
		self._console_box.hide()



func _set_readonly(value):
	Log.warn("qc/console: _set_readonly: Attempted to set a protected variable, ignoring.")
