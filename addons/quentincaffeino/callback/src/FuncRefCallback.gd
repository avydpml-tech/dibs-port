
extends "./AbstractCallback.gd"



func _init(target).(target, Utils.Type.METHOD):
	pass




func ensure():
	return self._target.is_valid()




func call(argv = []):
	
	if not ensure():
		print(errors["qc.callback.call.ensure_failed"] %[self._target])
		return

	
	return self._target.call_funcv(self._get_args(argv))
