extends Area2D

func _ready():
	$AnimatedSprite.play("idle")

func _on_Portal_body_entered(body):
	if body.get_name() == "Player":
		TransitionScreen1.change_scene("res://scenes/CharacterTurningCS.tscn")
