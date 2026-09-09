extends Node

# Автозагружаемый синглтон (autoload). Пишет диагностику на диск
# отдельным файлом на каждый запуск игры, с memory/objects/heartbeat,
# чтобы по последней строке в файле понять, где именно всё оборвалось.
#
# Пытается писать в публичную папку Download (видна в любом файловом
# менеджере без танцев с root), но это требует Custom Build + разрешения
# WRITE_EXTERNAL_STORAGE в экспорт-пресете (см. инструкцию отдельно).
# Если это не настроено — молча падает на user://, что работает ВСЕГДА,
# без единого разрешения, на любой версии Android.

var log_dir := ""
var log_file_path := ""
var session_id := ""
var _heartbeat_timer: Timer

func _ready():
	session_id = _make_session_id()
	log_dir = _prepare_log_dir()
	log_file_path = log_dir.plus_file("session_log.txt")

	_write_header()

	_heartbeat_timer = Timer.new()
	_heartbeat_timer.wait_time = 2.0
	_heartbeat_timer.autostart = true
	_heartbeat_timer.one_shot = false
	add_child(_heartbeat_timer)
	_heartbeat_timer.connect("timeout", self, "_on_heartbeat")

func _make_session_id() -> String:
	var t = OS.get_datetime()
	return "%04d-%02d-%02d_%02d-%02d-%02d" % [t.year, t.month, t.day, t.hour, t.minute, t.second]

func _prepare_log_dir() -> String:
	var dir = Directory.new()
	var candidates = []

	if OS.get_name() == "Android":
		# Попытка №1: публичная папка Download — нужен Custom Build.
		var downloads = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
		if downloads != "":
			candidates.append(downloads.plus_file("DiBS_Logs"))

	# Попытка №2 (всегда рабочая): приватная папка игры.
	# Путь на диске: /sdcard/Android/data/<package>/files/DiBS_Logs
	candidates.append("user://DiBS_Logs")

	for base in candidates:
		var full_path = base.plus_file(session_id)
		var err = dir.make_dir_recursive(full_path)
		if err == OK or dir.dir_exists(full_path):
			print("CrashLogger: пишу логи в ", full_path)
			return full_path
		else:
			print("CrashLogger: не смог создать ", full_path, " (код ", err, "), пробую следующий вариант")

	# Сюда доходим только если вообще всё сломано — пишем прямо в user://.
	return "user://"

func _write_header() -> void:
	_log("========== НОВАЯ СЕССИЯ ==========")
	_log("Время: " + str(OS.get_datetime()))
	_log("Платформа: " + OS.get_name())
	_log("Версия движка: " + Engine.get_version_info().get("string", "?"))
	_log("Путь лога: " + log_file_path)
	if has_node("/root/Globals"):
		var g = get_node("/root/Globals")
		if "game_version" in g:
			_log("Версия игры: " + str(g.game_version))
	_log_memory("старт")

func _on_heartbeat() -> void:
	_log_memory("heartbeat")

func _log_memory(tag: String) -> void:
	var static_mem = OS.get_static_memory_usage() / 1048576.0
	var static_peak = OS.get_static_memory_peak_usage() / 1048576.0
	var obj_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	var node_count = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var tex_mem = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0
	var vram = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	_log("[%s] RAM=%.1fMB(пик %.1fMB) объектов=%d нод=%d текстуры=%.1fMB VRAM=%.1fMB FPS=%.0f" % [
		tag, static_mem, static_peak, obj_count, node_count, tex_mem, vram, fps
	])

# Публичный метод — вызывай откуда угодно: CrashLog.log("текст")
func log_event(msg: String) -> void:
	_log(msg)

func _log(msg: String) -> void:
	var f = File.new()
	var err
	if f.file_exists(log_file_path):
		err = f.open(log_file_path, File.READ_WRITE)
		if err == OK:
			f.seek_end()
	else:
		err = f.open(log_file_path, File.WRITE)

	if err == OK:
		var ms = OS.get_ticks_msec()
		f.store_line("[t+%08dms] %s" % [ms, msg])
		f.close()  # close() = немедленный flush на диск, переживает краш
	else:
		print("CrashLogger: ошибка записи (код ", err, "): ", msg)
