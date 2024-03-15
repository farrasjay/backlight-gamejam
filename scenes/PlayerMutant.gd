extends KinematicBody2D

const GRAVITY = 20
const NORMAL_SPEED = 200
const JUMP_POWER = 300
const MAX_JUMP_COUNT = 3
const bulletPath = preload('res://scenes/MutantBulletProjectile.tscn')

var motion = Vector2()
var jumpCount = 0

var player_health = 3
var bandit_killed_counter = 0

var mutant_laser_sfx: AudioStream
var mutant_sword_sfx: AudioStream
var damaged_sfx: AudioStream

export var deathScreen = "DeathMenu"

func _ready():
	$Sprite.visible = true
	bandit_killed_counter = 0
	mutant_laser_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/mutant_laser.mp3")
	damaged_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/damaged.mp3")
	mutant_sword_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/mutant_sword.mp3")

func _physics_process(_delta):
	apply_gravity()

	handle_input()

	motion = move_and_slide(motion, Vector2.UP)
	
	if motion.y > 1250:
		get_tree().reload_current_scene()
		
	if bandit_killed_counter >= 1:
		$TaskLabel.text = "Proceed to altar"

func apply_gravity():
	motion.y += GRAVITY

func handle_input():
	var speed = NORMAL_SPEED
	
	if Input.is_action_pressed("attack"):
		$AnimationPlayer.play("attack")
		$AudioStreamPlayer2D.stream = mutant_sword_sfx
		$AudioStreamPlayer2D.play()
	
	if Input.is_action_just_pressed("laser"):
		shoot_laser()
		
	if Input.is_action_pressed("jump"):
		handle_jump_input()
		
	else:
		handle_movement_input(speed)

func handle_movement_input(speed):
	if Input.is_action_pressed("move_left"):
		move_left(speed)
		
	elif Input.is_action_pressed("move_right"):
		move_right(speed)
		
	else:
		stop_movement()

func handle_jump_input():
	if is_on_floor() and jumpCount != 0:
		jumpCount = 0

	if jumpCount < MAX_JUMP_COUNT and Input.is_action_just_pressed("jump"):
		motion.y = -JUMP_POWER
		jumpCount += 1

func move_left(speed=NORMAL_SPEED):
	motion.x = -speed
	$Sprite.flip_h = true
	$Detector.get_node("CollisionShape2D").position.x = -77
	$AttackDetector.get_node("CollisionShape2D").position.x = -51
	$AnimationPlayer.play("walk")

func move_right(speed=NORMAL_SPEED):
	motion.x = speed
	$Sprite.flip_h = false
	$Detector.get_node("CollisionShape2D").position.x = -2
	$AttackDetector.get_node("CollisionShape2D").position.x = 24
	$AnimationPlayer.play("walk")

func stop_movement():
	motion.x = 0
	
func shoot_laser():
	var spawn_position
	
	if $Sprite.flip_h:
		spawn_position = $LeftPosition2D.global_position
	else:
		spawn_position = $RightPosition2D.global_position
		
	var bullet = bulletPath.instance()
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - spawn_position).normalized()
	
	get_parent().add_child(bullet)

	bullet.global_position = spawn_position
	bullet.global_rotation = direction.angle()
	bullet.velocity = direction * bullet.speed
	
	$AudioStreamPlayer2D.stream = mutant_laser_sfx
	$AudioStreamPlayer2D.play()
	
func hit():
	$AttackDetector.monitoring = true

func end_of_hit():
	$AttackDetector.monitoring = false
	
func _on_Detector_body_entered(body):
	pass
	
func _on_AttackDetector_body_entered(body):
	if body.get_name() == "BanditEnemy":
		body.get_node("AnimationPlayer").play("on_hit")
		bandit_killed_counter += 1
		
		body.get_node("AudioStreamPlayer2D").stream = damaged_sfx
		body.get_node("AudioStreamPlayer2D").play()
		
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 0.4
		timer.one_shot = true
		timer.connect("timeout", self, "_on_hit_timer_timeout", [body])
		timer.start()

func _on_hit_timer_timeout(body):
	body.queue_free()
	
func update_health_counter():
	$HealthLabel.text = "Health: " + str(player_health)

func death_screen():
	get_tree().change_scene(str("res://scenes/" + deathScreen + ".tscn"))
