tool 
class_name FlexGridContainer, "res://addons/color-palette/utilities/FlexGridContainerIcon.png"
extends Container


var columns: int = 1 setget set_columns


func _notification(p_what):
	match p_what:
		NOTIFICATION_SORT_CHILDREN:
			var col_minw: Dictionary
			var row_minh: Dictionary
			var col_expanded: Array
			var row_expanded: Array

			var hsep = get_constant("hseparation", "GridContainer")
			var vsep = get_constant("vseparation", "GridContainer")
			
			var min_columns = 1
			
			if get_child_count() > 0:
				min_columns = int(floor(rect_size.x / (get_child(0).get_combined_minimum_size().x + hsep)))
			
			self.columns = min_columns
			
			var max_col = min(get_child_count(), columns)
			var max_row = ceil(float(get_child_count()) / float(columns))


			var valid_controls_index = 0
			for i in range(get_child_count()):
				var c: Control = get_child(i)
				if not c or not c.is_visible_in_tree():
					continue

				var row = valid_controls_index / columns
				var col = valid_controls_index % columns
				valid_controls_index += 1

				var ms: Vector2 = c.get_combined_minimum_size()
				if col_minw.has(col):
					col_minw[col] = max(col_minw[col], ms.x)
				else:
					col_minw[col] = ms.x
				if row_minh.has(row):
					row_minh[row] = max(row_minh[row], ms.y)
				else:
					row_minh[row] = ms.y

				if c.get_h_size_flags() & SIZE_EXPAND:
					col_expanded.push_front(col)
					
				if c.get_v_size_flags() & SIZE_EXPAND:
					row_expanded.push_front(row)


			for i in range(valid_controls_index, columns):
				col_expanded.push_front(i)


			var remaining_space: Vector2 = get_size()
			
			for e in col_minw.keys():
				if not col_expanded.has(e):
					remaining_space.x -= col_minw.get(e)

			for e in row_minh.keys():
				if not row_expanded.has(e):
					remaining_space.y -= row_minh.get(e)

			remaining_space.y -= vsep * max(max_row - 1, 0)
			remaining_space.x -= hsep * max(max_col - 1, 0)

			var can_fit = false
			while not can_fit and col_expanded.size() > 0:

				can_fit = true
				var max_index = col_expanded.front()
				
				for e in col_expanded:
					if col_minw.has(e):
						if col_minw[e] > col_minw[max_index]:
							max_index = e
						if can_fit and (remaining_space.x / col_expanded.size()) < col_minw[e]:
							can_fit = false


				if ( not can_fit):
					col_expanded.erase(max_index)
					remaining_space.x -= col_minw[max_index]

			can_fit = false
			while not can_fit and row_expanded.size() > 0:

				can_fit = true
				var max_index = row_expanded.front()
				
				for e in row_expanded:
					if row_minh[e] > row_minh[max_index]:
						max_index = e
					if can_fit and (remaining_space.y / row_expanded.size()) < row_minh[e]:
						can_fit = false


				if ( not can_fit):
					row_expanded.erase(max_index)
					remaining_space.y -= row_minh[max_index]


			var col_expand = remaining_space.x / col_expanded.size() if col_expanded.size() > 0 else 0
			var row_expand = remaining_space.y / row_expanded.size() if row_expanded.size() > 0 else 0

			var col_ofs = 0
			var row_ofs = 0

			valid_controls_index = 0
			for i in range(get_child_count()):
				var c: Control = get_child(i)
				if ( not c or not c.is_visible_in_tree()):
					continue
				var row = valid_controls_index / columns
				var col = valid_controls_index % columns
				valid_controls_index += 1

				if (col == 0):
					col_ofs = 0
					if (row > 0):
						row_ofs += (row_expand if row_expanded.has(row - 1) else row_minh[row - 1]) + vsep

				var p = Vector2(col_ofs, row_ofs)
				var s = Vector2(col_expand if col_expanded.has(col) else col_minw[col], row_expand if row_expanded.has(row) else row_minh[row])

				fit_child_in_rect(c, Rect2(p, s))

				col_ofs += s.x + hsep
				
		NOTIFICATION_THEME_CHANGED:
			minimum_size_changed()

func _get_minimum_size():

	var row_minh: Dictionary

	var vsep = get_constant("vseparation", "GridContainer")

	var max_row = 0

	var valid_controls_index = 0
	for i in range(get_child_count()):

		var c: Control = get_child(i)
		if not c or not c.is_visible():
			continue
		var row = valid_controls_index / columns
		valid_controls_index += 1

		var ms = c.get_combined_minimum_size()

		if row_minh.has(row):
			row_minh[row] = max(row_minh[row], ms.y)
		else:
			row_minh[row] = ms.y
		max_row = max(row, max_row)

	var ms: Vector2

	for e in row_minh.keys():
		ms.y += row_minh.get(e)

	ms.y += vsep * max_row

	return ms


func set_columns(p_columns: int):
	columns = p_columns
	minimum_size_changed()
