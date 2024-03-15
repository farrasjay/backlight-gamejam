extends Node2D

func _ready():
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	TransitionScreen1.change_scene("res://scenes/Prologue.tscn")
