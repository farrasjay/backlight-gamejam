extends Area2D

func _ready():
	$AnimatedSprite.play("idle")

func _on_Altar_body_entered(body):
	if body.get_name() == "PlayerMutant" and body.bandit_killed_counter >= 1:
		TransitionScreen1.change_scene("res://scenes/CreditsScene.tscn")
	else:
		pass
