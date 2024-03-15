extends Button

func _ready():
	pass

func _on_TestButton2_pressed():
	get_tree().change_scene(str("res://scenes/Prologue.tscn"))
