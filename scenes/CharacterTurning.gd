extends Node2D

var idle_timer := Timer.new()
var mutant_timer := Timer.new()

func _ready():
	add_child(idle_timer)
	add_child(mutant_timer)
	
	idle_timer.connect("timeout", self, "_on_idle_timer_timeout")
	mutant_timer.connect("timeout", self, "_on_mutant_timer_timeout")

	idle_timer.wait_time = 1.1
	idle_timer.one_shot = true
	idle_timer.start()

	$AnimationPlayer.play("idle")
	$PlayerSprite.visible = true
	$MutantSprite.visible = false

func _on_idle_timer_timeout():
	$PlayerSprite.visible = false
	$MutantSprite.visible = true
	
	mutant_timer.wait_time = 2.75
	mutant_timer.one_shot = true
	mutant_timer.start()

	$AnimationPlayer.play("idle_mutant")

func _on_mutant_timer_timeout():
	TransitionScreen1.change_scene("res://scenes/SecondLevel.tscn")
