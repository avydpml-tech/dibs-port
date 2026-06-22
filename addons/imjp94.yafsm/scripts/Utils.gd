
static func popup_on_target(popup, target):
	popup.set_as_minsize()
	var usable_rect = Rect2(Vector2.ZERO, OS.get_real_window_size())
	var cp_rect = Rect2(Vector2.ZERO, popup.get_size())
	for i in 4:
		if i > 1:
			cp_rect.position.y = target.rect_global_position.y - cp_rect.size.y
		else:
			cp_rect.position.y = target.rect_global_position.y + target.get_size().y

		if i & 1:
			cp_rect.position.x = target.rect_global_position.x
		else:
			cp_rect.position.x = target.rect_global_position.x - max(0, cp_rect.size.x - target.get_size().x)

		if usable_rect.encloses(cp_rect):
			break
	popup.set_position(cp_rect.position)
	popup.popup()

static func get_complementary_color(color):
	var r = max(color.r, max(color.b, color.g)) + min(color.r, min(color.b, color.g)) - color.r
	var g = max(color.r, max(color.b, color.g)) + min(color.r, min(color.b, color.g)) - color.g
	var b = max(color.r, max(color.b, color.g)) + min(color.r, min(color.b, color.g)) - color.b
	return Color(r, g, b)

class CohenSutherland:
	const INSIDE = 0
	const LEFT = 1
	const RIGHT = 2
	const BOTTOM = 4
	const TOP = 8

	
	static func compute_code(x, y, x_min, y_min, x_max, y_max):
		var code = INSIDE
		if x < x_min:
			code |= LEFT
		elif x > x_max:
			code |= RIGHT
		
		if y < y_min:
			code |= BOTTOM
		elif y > y_max:
			code |= TOP
		
		return code

	
	
	
	static func line_intersect_rectangle(from, to, rect):
		var x_min = rect.position.x
		var y_min = rect.position.y
		var x_max = rect.end.x
		var y_max = rect.end.y

		var code0 = compute_code(from.x, from.y, x_min, y_min, x_max, y_max)
		var code1 = compute_code(to.x, to.y, x_min, y_min, x_max, y_max)

		var i = 0
		while true:
			i += 1
			if not (code0 | code1):
				return true
			elif code0 & code1:
				return false
			else:
				
				
				var x
				var y
				var code_out = max(code0, code1)

				
				
				
				
				if code_out & TOP:
					x = from.x + (to.x - from.x) * (y_max - from.y) / (to.y - from.y)
					y = y_max
				elif code_out & BOTTOM:
					x = from.x + (to.x - from.x) * (y_min - from.y) / (to.y - from.y)
					y = y_min
				elif code_out & RIGHT:
					y = from.y + (to.y - from.y) * (x_max - from.x) / (to.x - from.x)
					x = x_max
				elif code_out & LEFT:
					y = from.y + (to.y - from.y) * (x_min - from.x) / (to.x - from.x)
					x = x_min

				
				if code_out == code0:
					from.x = x
					from.y = y
					code0 = compute_code(from.x, from.y, x_min, y_min, x_max, y_max)
				else:
					to.x = x
					to.y = y
					code1 = compute_code(to.x, to.y, x_min, y_min, x_max, y_max)
