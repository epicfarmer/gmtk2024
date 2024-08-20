class_name Player2D

extends CharacterBody2D

@onready var camera: Camera2D = $Camera
@onready var animated_sprite = $AnimatedSprite2D
@onready var coyote_timer = $CoyoteTimer
@onready var player = $AnimationPlayer
@onready var jump_audio = $JumpSound
@onready var spring_jump_audio = $SpringJumpSound
@onready var death_audio = $DeathSound

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const SPRING_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote = false
var jumping = false
var last_floor = false
var dying = false

func _ready():
	get_parent().inside = true
var spring = null

func _physics_process(delta):
	# Add the gravity.
	if dying:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_home"):
		camera.zoom = Vector2(12,12)
	if Input.is_action_just_released("ui_home"):
		camera.zoom = Vector2(1,1)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote):
		jumping = true
		if spring != null:
			velocity.y = SPRING_VELOCITY
			spring.play_spring()
			spring_jump_audio.play()
		else:
			jump_audio.play()
			velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jump"):
		if velocity.y < JUMP_VELOCITY: # early out for springboard
			velocity.y = JUMP_VELOCITY
		elif velocity.y < -100:
			velocity.y = -100
	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump") 
	
	if is_on_floor() and jumping:
		jumping = false
	if !is_on_floor() and last_floor and !jumping:
		coyote = true
		coyote_timer.start()
	last_floor = is_on_floor()
	
func enable_camera() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and key_event.keycode == KEY_ESCAPE:
			print("Quitting")
			get_tree().quit()

func _on_coyote_timer_timeout():
	coyote = false

func fade_to_black():
	player.play("die")

func die():
	dying = true
	AudioManager.stop()
	death_audio.play()
	fade_to_black()
