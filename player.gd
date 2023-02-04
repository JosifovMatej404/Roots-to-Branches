extends KinematicBody2D

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var speed = Vector2(100,100)
var state_machine
var grav = 2
var on_floor = false

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")

func _get_direction() -> Vector2:
	return Vector2(
	Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
	-1.0 if Input.is_action_just_pressed("ui_up") && on_floor else 1.0)

func _calculate_move_velocity(
	linear_velocity: Vector2,
	directions: Vector2,
	speedy:Vector2) -> Vector2:
	var new_velocity = linear_velocity
	new_velocity.x = speedy.x * directions.x
	new_velocity.y += grav * get_physics_process_delta_time()

	if is_on_floor() == true:
		on_floor = true
	else:
		on_floor = false

	return new_velocity
	
func _physics_process(delta):
		direction = _get_direction()
		velocity = _calculate_move_velocity(velocity, direction, speed)
		_manage_animations()
		move_and_slide(velocity, Vector2.UP)

func _manage_animations():
	if Input.is_action_pressed("attack"):
		_attack()
		return
	if direction.x != 0:
		state_machine.travel("run")
		return
	state_machine.travel("idle")
	
func _attack():
	#if on_floor:
	state_machine.travel("attack")
	velocity = Vector2.ZERO
