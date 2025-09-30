extends CharacterBody3D

# --- Movimiento ---
@export var max_speed: float = 4.0
@export var accel: float = 10.0
@export var friction: float = 8.0
@export var jump_velocity: float = 4.5
@export var camera_limit: float = 89.0

# --- Cámara ---
@onready var camera_pivot: Node3D = $cameraPivot
@export var mouse_sensitivity: float = 0.002

# --- Head Bobbing ---
@export var bob_speed: float = 6.0
@export var bob_amount: float = 0.04
var bob_timer: float = 0.0
var base_camera_pos: Vector3

# --- Rotaciones ---
var rotation_x := 0.0
var rotation_y := 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	base_camera_pos = camera_pivot.position

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_y -= event.relative.x * mouse_sensitivity
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-camera_limit), deg_to_rad(camera_limit))

func _physics_process(delta: float) -> void:
	# --- rotación inmediata ---
	camera_pivot.rotation.x = rotation_x
	rotation.y = rotation_y

	# --- movimiento ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var hvel = velocity
	hvel.y = 0

	var target = direction * max_speed
	var applied_accel = accel if direction != Vector3.ZERO else friction

	hvel = hvel.lerp(target, applied_accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z

	move_and_slide()

	# --- head bobbing ---
	if direction.length() > 0.1 and is_on_floor():
		bob_timer += delta * bob_speed
		var offset_y = sin(bob_timer * 2.0) * bob_amount
		var offset_x = sin(bob_timer) * bob_amount * 0.5
		camera_pivot.position = base_camera_pos + Vector3(offset_x, offset_y, 0)
	else:
		bob_timer = 0.0
		camera_pivot.position = camera_pivot.position.lerp(base_camera_pos, delta * 8.0)
