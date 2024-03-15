extends Button

func _ready():
	pass

func _on_CreditButton_pressed():
	TransitionScreen1.change_scene(str("res://scenes/CreditsScene.tscn"))
