extends Node2D

export (PackedScene) var bandit

func _ready():
	repeat()

func spawn():
	call_deferred("_spawn_enemy")
	
func _spawn_enemy():
	var spawned = bandit.instance()
	get_parent().add_child(spawned)

	var spawn_pos = global_position
	spawn_pos.x = spawn_pos.x + rand_range(-100, 100)

	spawned.global_position = spawn_pos

func repeat():
	spawn()
	var timer = Timer.new()
	timer.wait_time = 6
	timer.one_shot = true
	timer.connect("timeout", self, "repeat")
	add_child(timer)
	timer.start()
