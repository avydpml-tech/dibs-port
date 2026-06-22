
extends Reference



var _root



func _init():
	self._root = TrieNode.new()







func insert(key, value):
	var current_node = self._root

	var length = len(key)
	for level in range(length):
		var index = key[level]

		
		if not current_node.has_child(index):
			current_node.initialize_child_at(index)

		current_node = current_node.get_child(index)

	if current_node.value:
		return

	current_node.value = value






func has(key):
	return not not self.get(key)






func get(key):
	var current_node = self._root

	var length = len(key)
	for level in range(length):
		var index = key[level]

		if not current_node.has_child(index):
			return null

		current_node = current_node.get_child(index)

	return current_node.value



class TrieNode:

	
	var _children

	
	var value


	
	func _init():
		self._children = {}
		self.value = null


	
	func get_children():
		return self._children


	
	
	func has_child(index):
		return index in self._children

	
	
	func get_child(index):
		return self._children[index]

	
	
	func initialize_child_at(index):
		self._children[index] = TrieNode.new()
