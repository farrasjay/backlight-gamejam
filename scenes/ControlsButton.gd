extends Button

func _ready():
	pass

func _on_ControlsButton_pressed():
	TransitionScreen1.change_scene(str("res://scenes/ControlMenu.tscn"))
