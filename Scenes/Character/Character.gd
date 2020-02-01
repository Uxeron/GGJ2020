extends KinematicBody2D

# This demo shows how to build a kinematic controller.

# Member variables
const GRAVITY : float = 500.0 # pixels/second^2

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE : float = 40.0
const WALK_SPEED : float = 200.0
const JUMP_SPEED : float = 400.0
const JUMP_MAX_AIRBORNE_TIME : float = 0.1

const SLIDE_STOP_VELOCITY : float = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL : float = 1.0 # one pixel

var velocity : = Vector2()
var on_air_time : float = 100.0
var jumping : bool = false

var prev_jump_pressed : bool = false


func _physics_process(delta):
	# Create forces
	var force : = Vector2(0.0, GRAVITY)

	var walk_left : bool = Input.is_action_pressed("move_left")
	var walk_right : bool = Input.is_action_pressed("move_right")
	var jump : bool = Input.is_action_pressed("move_jump")

	if walk_left:
		if not $AnimatedSprite.is_playing() or $AnimatedSprite.animation == "Walk_Right":
			$AnimatedSprite.play("Walk_Left")
		
		velocity.x = -WALK_SPEED
	elif walk_right:
		if not $AnimatedSprite.is_playing() or $AnimatedSprite.animation == "Walk_Left":
			$AnimatedSprite.play("Walk_Right")
		
		velocity.x = WALK_SPEED
	else:
		if Input.is_action_just_released("move_left"):
			$AnimatedSprite.animation = "Stand_Left"
		if Input.is_action_just_released("move_right"):
			$AnimatedSprite.animation = "Stand_Right"
		
		$AnimatedSprite.frame = 0
		$AnimatedSprite.stop()
		
		velocity.x = 0.0
	
	# Draw in-air character
	if not is_on_floor():
		if velocity.x > 0.0:
			if $AnimatedSprite.animation != "Walk_Right":
				$AnimatedSprite.play("Walk_Right")
		
		if velocity.x < 0.0:
			if $AnimatedSprite.animation != "Walk_Left":
				$AnimatedSprite.play("Walk_Left")
		
		$AnimatedSprite.frame = 2
		$AnimatedSprite.stop()

	# Integrate forces to velocity
	velocity += force * delta
	# Integrate velocity into motion and move
	velocity = move_and_slide(velocity, Vector2(0, -1))

	if is_on_floor():
		on_air_time = 0

	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false

	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true

	on_air_time += delta
	prev_jump_pressed = jump
