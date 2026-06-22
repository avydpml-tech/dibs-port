
extends Reference


enum TYPE\
{
	DEBUG, 
	INFO, 
	WARNING, 
	ERROR, 
	NONE
}



var logLevel = TYPE.WARNING




func set_log_level(in_log_level):
	logLevel = in_log_level
	return self









func log(message, type = TYPE.INFO):
	match type:
		TYPE.DEBUG: debug(message)
		TYPE.INFO: info(message)
		TYPE.WARNING: warn(message)
		TYPE.ERROR: error(message)
	return self




func debug(message):
	if logLevel <= TYPE.DEBUG:
		Console.write_line("[color=green][DEBUG][/color] " + str(message))
	return self




func info(message):
	if logLevel <= TYPE.INFO:
		Console.write_line("[color=blue][INFO][/color] " + str(message))
	return self




func warn(message):
	if logLevel <= TYPE.WARNING:
		Console.write_line("[color=yellow][WARNING][/color] " + str(message))
	return self




func error(message):
	if logLevel <= TYPE.ERROR:
		Console.write_line("[color=red][ERROR][/color] " + str(message))
	return self
