extends Area2D

func _ready():
	$AnimatedSprite.play("idle")

func _on_PowerupShield_body_entered(body):
	if body.get_name() == "Player":
		body.player_health = 2
		body.get_node("ShieldSprite").visible = true
		body.get_node("ShieldAnimation").play("shield_activated")
		body.update_shield_status("Activated")
		queue_free()
