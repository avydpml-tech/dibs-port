extends Node2D

# РЕКОНСТРУКЦИЯ: оригинальный .gd потерян, есть был только .gdc (байткод).
# Восстановлено по структуре openingScene.tscn (какие кнопки на что подписаны).
# Все пути — строки, грузятся лениво через SceneChanger, а не жадно при
# парсинге сцены (в этом и была вторая причина крашей).

export (String) var scene_path_to_load = "res://Src/1_World/1_zones/ship/Stage_01.tscn"
export (String) var quick_start = "res://Src/1_World/1_zones/ship/Stage_05-Canals.tscn"
export (String) var warehouse = "res://Src/1_World/1_zones/ship/Stage_09-Warehouse.tscn"
export (String) var cinema = "res://Src/1_World/1_zones/MallZones/Stage_01_b-CinemaRoom.tscn"
export (String) var mall = "res://Src/1_World/1_zones/MallZones/Stage_02_b-Mall.tscn"

func _ready():
	pass

# PlayButton -> начать игру с самого начала
func _on_PlayButton_pressed():
	get_node("/root/SceneChanger")._change_scene(scene_path_to_load)

# OptionsButton -> показать панель настроек, скрыть главное меню
func _on_OptionsButton_pressed():
	$Control2/MarginContainer/VBoxContainer.visible = true
	$Control2/MarginContainer/VBoxContainer2.visible = false

# BackButton -> вернуться из настроек в главное меню
func _on_BackButton_pressed():
	$Control2/MarginContainer/VBoxContainer.visible = false
	$Control2/MarginContainer/VBoxContainer2.visible = true

# Button3 = "QUIT"
func _on_Button3_pressed():
	get_tree().quit()

# "Debug Level" -> открыть панель быстрых переходов (Quick Start/Warehouse/...)
# TODO: проверь — возможно, оригинал делал что-то другое (например, включал
# консоль addons/quentincaffeino вместо этого)
func _on_debug_pressed():
	$Control2/shortcuts/more_options.visible = not $Control2/shortcuts/more_options.visible

# TODO: не смог восстановить оригинальную логику — предположительно
# переключает раскладку управления на QWERTY через GGS-аддон/Globals.
# Оставил заглушкой, чтобы не падало на несуществующем методе.
func _on_ggsBool3_pressed():
	pass

func _on_quick_start_pressed():
	get_node("/root/SceneChanger")._change_scene(quick_start)

func _on_warehouse_pressed():
	get_node("/root/SceneChanger")._change_scene(warehouse)

func _on_theatre_pressed():
	get_node("/root/SceneChanger")._change_scene(cinema)

func _on_mall_pressed():
	get_node("/root/SceneChanger")._change_scene(mall)
