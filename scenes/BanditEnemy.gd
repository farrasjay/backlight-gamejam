extends KinematicBody2D

const GRAVITY = 20
const SPEED = 50

var velocity = Vector2()
var is_moving_left = true
var shield_break_sfx: AudioStream
var damaged_sfx: AudioStream
var bandit_sword_sfx: AudioStream

func _ready():
	start_walking_anim()
	shield_break_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/shield_break.mp3")
	damaged_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/damaged.mp3")
	bandit_sword_sfx = load("res://assets/sfx/SuperGrottoEScape Audio Music Files/bandit_sword.mp3")

func _physics_process(delta):
	if $AnimationPlayer.current_animation == "attack":
		return
	
	move_character()
	detect_turn_around()

func move_character():
	velocity.x = -SPEED if is_moving_left else SPEED
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, Vector2.UP)
	
func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		is_moving_left = !is_moving_left
		scale.x = -scale.x

func start_walking_anim():
	$AnimationPlayer.play("walk")
	
func hit():
	$AttackDetector.monitoring = true

func end_of_hit():
	$AttackDetector.monitoring = false

func _on_Detector_body_entered(body):
	if $Detector.get_node("CollisionShape2D").disabled:
		return
	elif body.get_name() == "Player" or "PlayerMutant":
		$AnimationPlayer.play("attack")
		$AudioStreamPlayer2D.stream = bandit_sword_sfx
		$AudioStreamPlayer2D.play()

func _on_AttackDetector_body_entered(body):
	var player = body
	if body.get_name() == "Player":
		if body.player_health == 2:
			player.player_health -= 1
			player.update_shield_status("Deactivated")
			player.get_node("ShieldSprite").visible = false
			player.get_node("ShieldBreaks").visible = true
			player.get_node("ShieldAnimation").play("shield_deactivated")
			player.get_node("AudioStreamPlayer2D").stream = shield_break_sfx
			player.get_node("AudioStreamPlayer2D").play()
			
		else:
			match player.get_node("AnimatedSprite").flip_h:
				true:
					player.get_node("AnimatedSprite").visible = false
					player.get_node("AnimatedSprite").stop()
					player.get_node("Sprite").visible = true
					player.get_node("AnimationPlayer").play("on_hit_right")
				false:
					player.get_node("AnimatedSprite").visible = false
					player.get_node("AnimatedSprite").stop()
					player.get_node("Sprite").visible = true
					player.get_node("AnimationPlayer").play("on_hit_left")
			
			player.get_node("AudioStreamPlayer2D").stream = damaged_sfx
			player.get_node("AudioStreamPlayer2D").play()
			
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = 0.6
			timer.one_shot = true
			timer.connect("timeout", self, "hit_player")
			timer.start()
			
	if body.get_name() == "PlayerMutant":
		player.get_node("AudioStreamPlayer2D").stream = damaged_sfx
		player.get_node("AudioStreamPlayer2D").play()	
		
		if body.player_health > 1:
			player.player_health -= 1
			player.get_node("AnimationPlayer").play("on_hit")
			player.update_health_counter()
			
		else:
			player.get_node("AnimationPlayer").play("on_hit")
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = 0.45
			timer.one_shot = true
			timer.connect("timeout", self, "hit_player")
			timer.start()

func _on_BanditHitbox_body_entered(body):
	if body.get_name() == "BulletProjectile" or body.get_name() == "MutantBulletProjectile":
		call_deferred("_disable_hit_player")
		$AnimationPlayer.play("on_hit")
		$AudioStreamPlayer2D.stream = damaged_sfx
		$AudioStreamPlayer2D.play()
		body.queue_free()
		
		var timer = Timer.new()
		add_child(timer)
		
		timer.wait_time = 0.4
		timer.one_shot = true
		timer.connect("timeout", self, "_on_hit_timer_timeout")
		timer.start()
		
func _disable_hit_player():
	$Detector.get_node("CollisionShape2D").disabled = true

func _on_hit_timer_timeout():
	queue_free()
	
func hit_player():
	get_tree().reload_current_scene()
