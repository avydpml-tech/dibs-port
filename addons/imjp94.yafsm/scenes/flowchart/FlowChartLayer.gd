tool 
extends Control
const FlowChartNode = preload("res://addons/imjp94.yafsm/scenes/flowchart/FlowChartNode.gd")

var content_lines = Control.new()
var content_nodes = Control.new()

var _connections = {}

func _init():
	name = "FlowChartLayer"
	mouse_filter = MOUSE_FILTER_IGNORE

	content_lines.name = "content_lines"
	content_lines.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(content_lines)
	move_child(content_lines, 0)

	content_nodes.name = "content_nodes"
	content_nodes.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(content_nodes)

func hide_content():
	content_nodes.hide()
	content_lines.hide()

func show_content():
	content_nodes.show()
	content_lines.show()


func get_scroll_rect(scroll_margin = 0):
	var rect = Rect2()
	for child in content_nodes.get_children():
		var child_rect = child.get_rect()
		rect = rect.merge(child_rect)
	return rect.grow(scroll_margin)


func add_node(node):
	content_nodes.add_child(node)


func remove_node(node):
	if node:
		content_nodes.remove_child(node)


func _connect_node(connection):
	content_lines.add_child(connection.line)
	connection.join()


func _disconnect_node(connection):
	content_lines.remove_child(connection.line)
	return connection.line


func rename_node(old, new):
	for from in _connections.keys():
		if from == old:
			var from_connections = _connections[from]
			_connections.erase(old)
			_connections[new] = from_connections
		else:
			for to in _connections[from].keys():
				if to == old:
					var from_connection = _connections[from]
					var value = from_connection[old]
					from_connection.erase(old)
					from_connection[new] = value


func connect_node(line, from, to, interconnection_offset = 0):
	if from == to:
		return
	var connections_from = _connections.get(from)
	if connections_from:
		if to in connections_from:
			return
	var connection = Connection.new(line, content_nodes.get_node(from), content_nodes.get_node(to))
	if not connections_from:
		connections_from = {}
		_connections[from] = connections_from
	connections_from[to] = connection
	_connect_node(connection)

	
	connections_from = _connections.get(to)
	if connections_from:
		var inv_connection = connections_from.get(from)
		if inv_connection:
			connection.offset = interconnection_offset
			inv_connection.offset = interconnection_offset
			connection.join()
			inv_connection.join()


func disconnect_node(from, to):
	var connections_from = _connections.get(from)
	var connection = connections_from.get(to)
	if not connection:
		return

	_disconnect_node(connection)
	if connections_from.size() == 1:
		_connections.erase(from)
	else:
		connections_from.erase(to)

	connections_from = _connections.get(to)
	if connections_from:
		var inv_connection = connections_from.get(from)
		if inv_connection:
			inv_connection.offset = 0
			inv_connection.join()
	return connection.line


func clear_connections():
	for connections_from in _connections.values():
		for connection in connections_from.values():
			connection.line.queue_free()
	_connections.clear()
			

func get_connection_list():
	var connection_list = []
	for connections_from in _connections.values():
		for connection in connections_from.values():
			connection_list.append({"from": connection.from_node.name, "to": connection.to_node.name})
	return connection_list

class Connection:
	var line
	var from_node
	var to_node
	var offset = 0

	func _init(p_line, p_from_node, p_to_node):
		line = p_line
		from_node = p_from_node
		to_node = p_to_node

	
	func join():
		line.join(get_from_pos(), get_to_pos(), offset, [from_node.get_rect() if from_node else Rect2(), to_node.get_rect() if to_node else Rect2()])

	
	func get_from_pos():
		return from_node.rect_position + from_node.rect_size / 2

	
	func get_to_pos():
		return to_node.rect_position + to_node.rect_size / 2 if to_node else line.rect_position
