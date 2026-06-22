
extends "./Collection.gd"



var _max_length = - 1



func get_max_length():
	return self._max_length



func set_max_length(max_length):
	self._max_length = max_length
	return self




func push(value):
	if self.length >= 0 and self.last() == value:
		return

	if self.length == self.get_max_length():
		self.pop()

	self.add(value)
	self.last()
	return self



func pop():
	var value = self.get_by_index(0)
	self.remove_by_index(0)
	return value
