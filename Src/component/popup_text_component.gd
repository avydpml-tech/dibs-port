extends Node2D


func set_text(text: String):
	$text / popup / Label.text = text
	$text / popup / AnimationPlayer.stop()
	$text / popup / AnimationPlayer.play("show_text")