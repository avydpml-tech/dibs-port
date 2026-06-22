
extends "Utils.gd"

const Iterator = preload("res://addons/quentincaffeino/iterator/src/Iterator.gd")



var _collection


var _iterationCurrent = 0


var length setget _set_readonly, length



func _init(collection = {}):
	self.replace_collection(collection)




func replace_collection(collection):
	self._collection = self.to_dict(collection)






func set(key, value):
	self._collection[key] = value





func add(value):
	self.set(self.length, value)





func remove(key):
	self._collection.erase(key)





func remove_element(element):
	for key in self._collection:
		if self._collection[key] == element:
			self._collection.erase(key)
			return true

	return false




func remove_by_index(index):
	var keys = self._collection.keys()

	if index >= 0 and index < keys.size():
		self._collection.erase(keys[index])





func contains_key(key):
	return self._collection.has(key)








func contains(element):
	for key in self._collection:
		if self._collection[key] == element:
			return true

	return false








func index_of(element):
	for key in self._collection:
		if self._collection[key] == element:
			return key

	return null





func get(key):
	if self.contains_key(key):
		return self._collection[key]

	return null




func get_by_index(index):
	var keys = self._collection.keys()

	if index >= 0 and index < keys.size():
		return self._collection[keys[index]]

	return null




func get_keys():
	return self._collection.keys()




func get_values():
	return self._collection.values()




func is_empty():
	return self.length == 0




func clear():
	self._collection = {}







func slice(offset, length = null):
	var result = get_script().new()

	if offset < self.length:
		if length == null:
			length = self.length

		var i = 0
		while length and i < self.length:
			result.set(i, self.get_by_index(offset + i))
			length -= 1
			i += 1

	return result







func fill(value = null, startIndex = 0, length = null):
	if startIndex < self.length:
		if length == null:
			length = self.length

		while length:
			self._collection[startIndex] = value
			startIndex += 1
			length -= 1

	return self




func map(callback):
	for key in self:
		self._collection[key] = callback.call([self._collection[key], key, self._collection])

	self.first()
	return self




func filter(callback = null):
	var new_collection = self.get_script().new(self.get_collection().duplicate())

	var i = 0
	if callback:
		var call

		while i < new_collection.length:
			var key = new_collection.get_keys()[i]
			var value = new_collection.get(key)

			call = callback.call([key, value, i, new_collection])

			if not call:
				new_collection.remove_by_index(i)
			else:
				i += 1
	else:
		while i < new_collection.length:
			var value = new_collection.get_by_index(i)
			if value == null or typeof(value) == TYPE_NIL or len(value) == 0:
				new_collection.remove_by_index(i)
			else:
				i += 1

	return new_collection




func first():
	if self.length:
		self._iterationCurrent = 0
		return self.get_by_index(self._iterationCurrent)

	return null




func last():
	if self.length:
		self._iterationCurrent = self.length - 1
		return self.get_by_index(self._iterationCurrent)

	return null




func key():
	if self.length:
		return self._iter_get()

	return null




func next():
	if self.length and self._iterationCurrent < self.length - 1:
		self._iterationCurrent += 1
		return self.get_by_index(self._iterationCurrent)

	return null




func previous():
	if self.length and self._iterationCurrent > 0:
		self._iterationCurrent -= 1
		return self.get_by_index(self._iterationCurrent)

	return null




func current():
	if self.length:
		return self._collection[self._iter_get()]

	return null



func get_collection():
	return self._collection



func length():
	return self._collection.size()



func size():
	return self._collection.size()




func _iter_init(arg):
	self._iterationCurrent = 0
	return self._iterationCurrent < self.length




func _iter_next(arg):
	self._iterationCurrent += 1
	return self._iterationCurrent < self.length




func _iter_get(arg = null):
	return self._collection.keys()[self._iterationCurrent]



func get_value_iterator():
	return Iterator.new(self, "get_by_index")



func _set_readonly(value):
	print("qc/array-utils: Collection: Attempted to set readonly value, ignoring.")
