extends KinematicBody2D

const GRAVITY = 20
const NORMAL_SPEED = 150
const JUMP_POWER = 300
const MAX_JUMP_COUNT = 2
const bulletPath = preload('res://scenes/BulletProjectile.tscn')

var motion = Vector2()
var jumpCount = 0

var player_health = 1
var ammo_counter = 6
var bandit_killed_counter = 0

var laser_beam_sfx: AudioStream
var shield_break_sfx: AudioStream
var damaged_sfx: AudioStream
var weapon_reload_sfx: AudioStream

export var deathScreen = "DeathMenu"

func _ready():
	$AnimatedSprite.visible = true
	$Sprite.visible = false
	$ShieldSprite.visible = false
	$ShieldBreaks.visible = false
	laser_beam_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/player_laser_blaster.mp3")
	shield_break_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/shield_break.mp3")
	damaged_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/damaged.mp3")
	weapon_reload_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/weapon_reload.mp3")

func _physics_process(_delta):
	apply_gravity()

	handle_input()

	motion = move_and_slide(motion, Vector2.UP)
	
	if motion.y > 1250:
		get_tree().reload_current_scene()

func apply_gravity():
	motion.y += GRAVITY

func handle_input():
	var speed = NORMAL_SPEED
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	if Input.is_action_just_pressed("reload"):
		reload()
		
	if Input.is_action_pressed("jump"):
		$AnimatedSprite.play("jump")
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
	$AnimatedSprite.flip_h = true
	$AnimatedSprite.play("walk")

func move_right(speed=NORMAL_SPEED):
	motion.x = speed
	$AnimatedSprite.flip_h = false
	$AnimatedSprite.play("walk")

func stop_movement():
	motion.x = 0
	$AnimatedSprite.play("idle")
	
func shoot():
	if ammo_counter == 0:
		reload()
		
	else:
		var spawn_position
		
		if $AnimatedSprite.flip_h:
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
		
		$AudioStreamPlayer2D.stream = laser_beam_sfx
		$AudioStreamPlayer2D.play()
		ammo_counter -= 1
		update_ammo_label()
	
func reload():
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 2.0
	timer.connect("timeout", self, "_on_reload_timeout")
	add_child(timer)
	timer.start()
	update_reloading_label()

func _on_reload_timeout():
	$AudioStreamPlayer2D.stream = weapon_reload_sfx
	$AudioStreamPlayer2D.play()
	ammo_counter = 6
	update_ammo_label()
	
func update_ammo_label():
	$AmmoCounterLabel.text = "Ammo: " + str(ammo_counter)

func update_reloading_label():
	$AmmoCounterLabel.text = "Reloading..."

func update_shield_status(status):
	match status:
		"Activated":
			$ShieldStatusLabel.text = "Shield Activated"
		"Deactivated":
			$ShieldStatusLabel.text = "Shield Deactivated"
	
func death_screen():
	get_tree().change_scene(str("res://scenes/" + deathScreen + ".tscn"))
