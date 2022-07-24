extends CharacterBody3D

var camera_angle_y_unfiltered:float = 0
var camera_angle_x_unfiltered:float = 0
var camera_angle_y_filtered:float = 0
var camera_angle_x_filtered:float = 0

# Use values like 0.1 for the next to smoothen camera angle changes more.
# This makes turning less responsive, but maybe easier to follow
# when creating videos etc.
const camera_angle_filter_coeff:float = 0.1
#const camera_angle_filter_coeff:float = 0.001	#0.01

enum NavigationMode {
	NAVMODE_FPS,
	NAVMODE_6DOF }

const mouse_sensitivity = 0.15
var camera_change = Vector2()
const ZAxisMax6DOFTurningSpeed:float = 90
const ZAxis6DOFTurningSpeedAcceleration = 0.9	# 0 = Don't turn, 1 = immediately full speed
var ZAxis6DOFTurningSpeed:float = 0
var last_camera_angle_x_filtered:float
var last_camera_angle_y_filtered:float
var navMode:NavigationMode = NavigationMode.NAVMODE_FPS

# Movement:
var direction:Vector3 = Vector3()
var velocityMultiplier:float = 5
const minVelocityMultiplier:float = 0.01
const maxVelocityMultiplier:float = 20
const flyAcceleration:float = 0.9	# 0 = don't move, 1 = immediately full speed
	

# Due to physics-process being run only 60 Hz and refresh rate
# may differ from that, head is moved "in advance" before
# the other parts. This is for the translation in world-coordinates for it
var headDetachment:Vector3 = Vector3()

var mouse_captured = false

func _ready():
	var manipulator = get_node("ManipulatorCollisionShape")
	var capsule = get_node("Capsule")
	var manipulatorMeshes = get_node("ManipulatorMeshes")

	manipulator.disabled = true
	manipulator.visible = true
	capsule.disabled = true
	manipulatorMeshes.visible = false

	var rmbManipulator = get_node("RMBManipulatorCollisionShape")
	var rmbManipulatorMeshes = get_node("RMBManipulatorMeshes")
	rmbManipulator.disabled = true
	rmbManipulator.visible = true
	rmbManipulatorMeshes.visible = false

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
#	var head:Node3D = get_node("Head")

	# Due to physics-process being run only 60 Hz and refresh rate
	# may differ from that, head is moved "in advance" before
	# the other parts.
	# The movement accumulated during _process-calls
	# is relayed to the physics-engine here
	velocity = headDetachment / delta # motion_velocity is in m/s, therefore /delta
	headDetachment = Vector3()	# Start accumulating from zero again
	var _discard = move_and_slide()

# Tried to prevent strange jitter with this. Didn't help
var lastUptime_us:int = -1
		
func _process(delta):
# Tried to prevent strange jitter with this. Didn't help
#	var upTime_us = Time.get_ticks_usec()
#	var deltaOverride = float(upTime_us - lastUptime_us) / 1e6
#	if (deltaOverride < 0.1):
#		delta = deltaOverride
#	lastUptime_us = upTime_us

	var manipulator = get_node("ManipulatorCollisionShape")
	var capsule = get_node("Capsule")
	var manipulatorMeshes = get_node("ManipulatorMeshes")
	var rmbManipulator = get_node("RMBManipulatorCollisionShape")
	var rmbManipulatorMeshes = get_node("RMBManipulatorMeshes")

	if Input.is_action_just_pressed('toggle_mouse'):
		if mouse_captured:
			mouse_captured = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			mouse_captured = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# This is outside the mouse_captured-branch below to keep flying speed
	# identical between all first persons (there may be many instances)
	handleFlyingSpeed(delta)

	if !mouse_captured or !(get_node("Head/FirstPersonCamera").current):
		# Do not react if camera is not in use
		# (There can be many instances of this class)
		manipulator.disabled = true
		capsule.disabled = true
		manipulatorMeshes.visible = false
		rmbManipulator.disabled = true
		rmbManipulatorMeshes.visible = false

		# Prevent annoying movements when changing to this camera due to remembering some old values
		camera_angle_y_unfiltered = camera_angle_y_filtered
		camera_angle_x_unfiltered = camera_angle_x_filtered
		direction = Vector3()
		velocity = Vector3()
		velocity = Vector3()
#		accumulatedVelocity = Vector3()
		camera_change = Vector2()

		return

	if mouse_captured:
		aim(delta)
		fly(delta)

		if Input.is_action_just_pressed("mouse_left"):
			manipulator.disabled = false
			capsule.disabled = false
			manipulatorMeshes.visible = true
		if Input.is_action_just_released("mouse_left"):
			manipulator.disabled = true
			capsule.disabled = true
			manipulatorMeshes.visible = false

		if Input.is_action_just_pressed("mouse_right"):
			rmbManipulator.disabled = false
			rmbManipulatorMeshes.visible = true
		if Input.is_action_just_released("mouse_right"):
			rmbManipulator.disabled = true
			rmbManipulatorMeshes.visible = false

func _input(event):
	if mouse_captured and (event is InputEventMouseMotion):
		camera_change += event.relative

func fly(delta):
	# reset the direction of the player
	direction = Vector3()
	
	# get the rotation of the camera
	var lookingAt = $Head/FirstPersonCamera.get_global_transform().basis
	
	# check input and change direction
	if Input.is_action_pressed("move_forward"):
		direction -= lookingAt.z
	if Input.is_action_pressed("move_backward"):
		direction += lookingAt.z
	if Input.is_action_pressed("move_left"):
		direction -= lookingAt.x
	if Input.is_action_pressed("move_right"):
		direction += lookingAt.x
	if (Input.is_action_pressed("move_up") ||
		(Input.is_action_pressed("6dof_rotate_z_right") && (navMode == NavigationMode.NAVMODE_FPS))):
		direction += lookingAt.y
	if (Input.is_action_pressed("move_down") ||
		(Input.is_action_pressed("6dof_rotate_z_left") && (navMode == NavigationMode.NAVMODE_FPS))):
		direction -= lookingAt.y

	# where would the player go at max speed (m/s)
	var target = direction * velocityMultiplier
	
	var correctedCoeff = pow(1 - flyAcceleration, delta)
	velocity = correctedCoeff * velocity + target * (1 - correctedCoeff)
#	print(velocity)
		
	var translation = velocity  * delta
	headDetachment += translation

	var head:Node3D = get_node("Head")
	head.set_transform(Transform3D(head.get_transform().basis, head.to_local(head.get_global_transform().origin + headDetachment)))

func handleFlyingSpeed(delta):
	if Input.is_action_pressed("movement_speed_down"):
		velocityMultiplier /= (1 + delta)
	if Input.is_action_just_released("movement_speed_down_mousewheel"):
		velocityMultiplier /= (1 + (delta * 20))

	if Input.is_action_pressed("movement_speed_up"):
		velocityMultiplier *= (1 + delta)
	if Input.is_action_just_released("movement_speed_up_mousewheel"):
		velocityMultiplier *= (1 + (delta * 20))

	velocityMultiplier = clamp(velocityMultiplier, minVelocityMultiplier, maxVelocityMultiplier)

func aim(delta):
	if Input.is_action_just_pressed("switch_navigation_mode"):
		if (navMode == NavigationMode.NAVMODE_FPS):
			navMode = NavigationMode.NAVMODE_6DOF
		else:
			navMode = NavigationMode.NAVMODE_FPS
			camera_angle_x_filtered = -rad2deg(asin(transform.basis.z.y))
			camera_angle_y_filtered = rad2deg(atan2(transform.basis.z.x, transform.basis.z.z))
			camera_angle_x_unfiltered = camera_angle_x_filtered
			camera_angle_y_unfiltered = camera_angle_y_filtered
			
	if (navMode == NavigationMode.NAVMODE_FPS):
		aimFPS(delta)
	else:
		aim6DOF(delta)
	

func aimFPS(delta):
	if camera_change.length() > 0:
#		$Head.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))
		camera_angle_y_unfiltered -= camera_change.x * mouse_sensitivity
		camera_angle_x_unfiltered -= camera_change.y * mouse_sensitivity
		
		if camera_angle_x_unfiltered < -90:
			camera_angle_x_unfiltered = -90
		if camera_angle_x_unfiltered > 90:
			camera_angle_x_unfiltered = 90
			
		camera_change = Vector2()
	
	transform.basis = Basis()

	var correctedCoeff = pow(camera_angle_filter_coeff, delta)
		
	camera_angle_x_filtered = camera_angle_x_filtered * correctedCoeff + camera_angle_x_unfiltered * (1 - correctedCoeff)
	camera_angle_y_filtered = camera_angle_y_filtered * correctedCoeff + camera_angle_y_unfiltered * (1 - correctedCoeff)
			
	last_camera_angle_x_filtered = camera_angle_x_filtered
	last_camera_angle_y_filtered = camera_angle_y_filtered

	rotate_x(deg2rad(camera_angle_x_filtered))
	rotate_y(deg2rad(camera_angle_y_filtered))

func aim6DOF(delta):
	if camera_change.length() > 0:
#		$Head.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))
		camera_angle_y_unfiltered -= camera_change.x * mouse_sensitivity
		camera_angle_x_unfiltered -= camera_change.y * mouse_sensitivity
		
		camera_change = Vector2()

	var correctedCoeff = pow(camera_angle_filter_coeff, delta)
		
	camera_angle_x_filtered = camera_angle_x_filtered * correctedCoeff + camera_angle_x_unfiltered * (1 - correctedCoeff)
	camera_angle_y_filtered = camera_angle_y_filtered * correctedCoeff + camera_angle_y_unfiltered * (1 - correctedCoeff)

	var camera_angle_x_filtered_change = camera_angle_x_filtered - last_camera_angle_x_filtered
	var camera_angle_y_filtered_change = camera_angle_y_filtered - last_camera_angle_y_filtered

	last_camera_angle_x_filtered = camera_angle_x_filtered
	last_camera_angle_y_filtered = camera_angle_y_filtered
	
	var unFilteredZAxisTurningSpeed = 0
	
	if Input.is_action_pressed("6dof_rotate_z_left"):
		unFilteredZAxisTurningSpeed += ZAxisMax6DOFTurningSpeed
	if Input.is_action_pressed("6dof_rotate_z_right"):
		unFilteredZAxisTurningSpeed -= ZAxisMax6DOFTurningSpeed

	correctedCoeff = pow(1 - ZAxis6DOFTurningSpeedAcceleration, delta)
	
	ZAxis6DOFTurningSpeed = ZAxis6DOFTurningSpeed * correctedCoeff + unFilteredZAxisTurningSpeed * (1 -  correctedCoeff)
	
	var tempBasis = transform.basis
	tempBasis = tempBasis.rotated(tempBasis.x, deg2rad(camera_angle_x_filtered_change))
	tempBasis = tempBasis.rotated(tempBasis.y, deg2rad(camera_angle_y_filtered_change))
	tempBasis = tempBasis.rotated(tempBasis.z, deg2rad(ZAxis6DOFTurningSpeed * delta))
	transform.basis = tempBasis.orthonormalized()

func set_LocationOrientation(newTransform: Transform3D):
	# TODO: should relay this to _physics_process instead
	# TODO: 6DOF?
	transform = newTransform
	transform.basis = Basis()
	var newBasis = newTransform.basis
	camera_angle_x_unfiltered = - rad2deg(asin(newBasis.z.y))
	camera_angle_x_filtered = camera_angle_x_unfiltered
	camera_angle_y_unfiltered = rad2deg(atan2(newBasis.z.x, newBasis.z.z))
	camera_angle_y_filtered = camera_angle_y_unfiltered
	rotate_x(deg2rad(camera_angle_x_filtered))
	rotate_y(deg2rad(camera_angle_y_filtered))
#	firstPerson.camera_change = Vector2(0,0)

	
