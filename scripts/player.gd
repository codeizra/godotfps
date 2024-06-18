extends CharacterBody3D

# Player Nodes
@onready var neck = $neck
@onready var head = $neck/head
@onready var eyes = $neck/head/eyes
@onready var standing_collision_shape_3d = $standingCollisionShape3D
@onready var crouching_collision_shape_3d = $crouchingCollisionShape3D
@onready var ray_cast_3d = $RayCast3D
@onready var camera_3d = $neck/head/eyes/Camera3D
@onready var animation_player = $neck/head/eyes/AnimationPlayer

# Speed vars
var currentSPEED = 3.5

const walkingSPEED = 3.5
const sprintingSPEED = 7.0
const crouchingSPEED = 1.0

# Movement vars
var lerp_speed = 10.0
var air_lerp_speed = 3.0

var crouching_depth = -0.5

var free_look_tilt_amount = 7

const JUMP_VELOCITY = 4.5

var last_velocity = Vector3.ZERO

# States
var walking = false
var sprinting = false
var crouching = false
var sliding = false
var free_looking = false

# Slide vars
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

# Head bobbing vars
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05

var head_bobbing_current_intensity = 0.0

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0

# Input vars
var direction = Vector3.ZERO
const mouse_sens = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Mouse Movement-Looking Logic
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Vector2()
	if Input.is_action_pressed("forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("backward"):
		input_dir.y += 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1
	
	# Handle Movement State
	
	# Crouching
	if Input.is_action_pressed("crouch") or sliding:
		currentSPEED = lerp(currentSPEED, crouchingSPEED, delta * lerp_speed)
		head.position.y = lerp(head.position.y, crouching_depth, delta * lerp_speed)
		
		standing_collision_shape_3d.disabled = true
		crouching_collision_shape_3d.disabled = false
		
		# Slide begin
		if sprinting and input_dir != Vector2.ZERO and is_on_floor():
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
			print("slide begins")
		elif sliding and Input.is_action_pressed("jump"):
			sliding = false
			velocity.y = JUMP_VELOCITY
			animation_player.play("jump")
		
		walking = false
		sprinting = false
		crouching = true
		
	elif not ray_cast_3d.is_colliding():
		# Standing
		standing_collision_shape_3d.disabled = false
		crouching_collision_shape_3d.disabled = true
		
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
		
		if Input.is_action_pressed("sprint") && input_dir.y < 0:
			# Sprinting
			currentSPEED = lerp(currentSPEED, sprintingSPEED, delta * lerp_speed)
			
			walking = false
			sprinting = true
			crouching = false
		
		else:
			# Walking
			currentSPEED = lerp(currentSPEED, walkingSPEED, delta * lerp_speed)
			
			walking = true
			sprinting = false
			crouching = false
		
	# Handle Free Looking
	if Input.is_action_pressed("free_look") or sliding:
		free_looking = true
		
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(7.0), delta * lerp_speed)
		else:
			eyes.rotation.z = -deg_to_rad(neck.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * lerp_speed)
			
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta
			
	# Handle sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			print("slide ends")
			free_looking = false
			
	# Handle headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
	
	if is_on_floor() and not sliding and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity/2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_player.play("jump")
		sliding = false
		
	# Handle landing
	if is_on_floor():
		if last_velocity.y < -10.0:
			animation_player.play("roll")
			print(last_velocity.y)
		elif last_velocity.y < -4.0:
			animation_player.play("landing")
			
		

	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)
	
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0.0, slide_vector.y)).normalized()
		currentSPEED = (slide_timer + 0.1) * slide_speed 
		
	if direction:
		velocity.x = direction.x * currentSPEED
		velocity.z = direction.z * currentSPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, currentSPEED)
		velocity.z = move_toward(velocity.z, 0, currentSPEED)

	last_velocity = velocity
	
	move_and_slide()
