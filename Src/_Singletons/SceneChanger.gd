extends CanvasLayer

signal scene_changed()

var current_scene: String = ""

const LOG_PATH = "user://crash_log.txt"

func _log(msg: String) -> void:
	# Пишем на диск и сразу закрываем файл (close() = flush),
	# чтобы строка гарантированно попала на диск ДО возможного краша.
	var f = File.new()
	var err
	if f.file_exists(LOG_PATH):
		err = f.open(LOG_PATH, File.READ_WRITE)
		if err == OK:
			f.seek_end()
	else:
		err = f.open(LOG_PATH, File.WRITE)

	if err == OK:
		var t = OS.get_datetime()
		f.store_line("[%02d:%02d:%02d] %s" % [t.hour, t.minute, t.second, msg])
		f.close()
	else:
		print("SceneChanger: не смог открыть лог, код ошибки ", err)

func _change_scene(path, fade_time = 0.2, hold_fade = 0, var delay = 0.1):
	_log("→ запрошен переход на: %s" % str(path))

	# Шаг 1: только загрузка ресурса. Если крашнется тут — в логе
	# останется только строка "запрошен переход", без "resource loaded".
	var res = ResourceLoader.load(path)

	if res == null:
		_log("✗ ОШИБКА: ResourceLoader.load вернул null для %s" % str(path))
		push_error("SceneChanger: не удалось загрузить сцену " + str(path))
		return

	_log("✓ ресурс загружен, вызываю change_scene_to()")

	# Шаг 2: собственно переключение (инстанцирование дерева сцены).
	current_scene = str(path)
	var tree_err = get_tree().change_scene_to(res)

	if tree_err != OK:
		_log("✗ ОШИБКА: change_scene_to вернул код %s" % str(tree_err))
		push_error("SceneChanger: change_scene_to failed: " + str(tree_err))
		return

	_log("✓ change_scene_to выполнен успешно")
	emit_signal("scene_changed")

func get_current_scene() -> String:
	return current_scene

# Вызови это откуда угодно (например, из debug-кнопки на warningScreen),
# чтобы прочитать лог прямо в игре без файлового менеджера.
func read_log() -> String:
	var f = File.new()
	if not f.file_exists(LOG_PATH):
		return "(лог пуст — файла ещё нет)"
	f.open(LOG_PATH, File.READ)
	var content = f.get_as_text()
	f.close()
	return content
