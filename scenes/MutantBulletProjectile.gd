extends KinematicBody2D

var velocity = Vector2(1, 0)
var speed = 250

const BULLET_LAYER = 1
const BULLET_MASK = 1
const PLAYER_MASK = 2

func _ready():
	$AnimatedSprite.play("ongoing")
	set_collision_layer(BULLET_LAYER)
	set_collision_mask(PLAYER_MASK)

	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_on_timeout")
	timer.wait_time = 2
	timer.start()

func _physics_process(delta):
	var collision_info = move_and_collide(velocity.normalized() * delta * speed)

	if collision_info:
		pass

func _on_timeout():
	queue_free()
