extends Button

func _ready():
	pass

func _on_BackButton_pressed():
	TransitionScreen1.change_scene(str("res://scenes/MainMenu.tscn"))
