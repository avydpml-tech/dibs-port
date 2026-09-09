extends CanvasLayer

signal scene_changed()

var current_scene: String = ""

func _change_scene(path, fade_time = 0.2, hold_fade = 0, delay = 0.1):
	var log = get_node_or_null("/root/CrashLog")

	if log:
		log.log_event("→ запрошен переход на: %s" % str(path))

	# Шаг 1: только загрузка ресурса.
	var res = ResourceLoader.load(path)

	if res == null:
		if log:
			log.log_event("✗ ОШИБКА: ResourceLoader.load вернул null для %s" % str(path))
		push_error("SceneChanger: не удалось загрузить сцену " + str(path))
		return

	if log:
		log.log_event("✓ ресурс загружен, вызываю change_scene_to()")

	# Шаг 2: собственно переключение (инстанцирование дерева сцены).
	current_scene = str(path)
	var tree_err = get_tree().change_scene_to(res)

	if tree_err != OK:
		if log:
			log.log_event("✗ ОШИБКА: change_scene_to вернул код %s" % str(tree_err))
		push_error("SceneChanger: change_scene_to failed: " + str(tree_err))
		return

	if log:
		log.log_event("✓ change_scene_to выполнен успешно")
	emit_signal("scene_changed")

func get_current_scene() -> String:
	return current_scene
