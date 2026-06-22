
extends "res://addons/quentincaffeino/console/src/Type/BaseRangeType.gd"





func _init(minValue = 0.0, maxValue = 100.0, step = 0.1).("FloatRange", minValue, maxValue, step):
	pass





func normalize(value):
	value = float(self._reextract(value).replace(",", "."))
	value = clamp(value, self.get_min_value(), self.get_max_value())

	if self._step != 0 and value != self.get_min_value():
		var prevVal = self.get_min_value()
		var curVal = self.get_min_value()

		while curVal < value:
			prevVal = curVal
			curVal += self._step

		if curVal - value < value - prevVal and curVal <= self.get_max_value():
			value = curVal
		else:
			value = prevVal

	return value
