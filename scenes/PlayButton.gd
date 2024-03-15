extends Button

func _ready():
	pass

func _on_PlayButton_pressed():
	TransitionScreen1.change_scene(str("res://scenes/Prologue.tscn"))
