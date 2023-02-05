extends KinematicBody2D

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var speed = Vector2(100,100)
var jump_power = 300
var state_machine
var grav = 500
var on_floor = false
var attacking
var is_dead = false
var quest_taken = false
var kills = 0

const hit_particles_scn = preload("res://hit_particles.tscn")
const explosion_scn = preload("res://explosion.tscn")


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
	
	if attacking:
		new_velocity = Vector2.ZERO
		
	if is_on_floor():
		on_floor = true
		new_velocity.y = 0

	if can_jump():
		new_velocity.y = -jump_power

	return new_velocity
	
func can_jump():
	if Input.is_action_pressed("jump") && on_floor && !attacking:
		state_machine.travel("jump_start")
		on_floor = false
		return true
	return false

func _physics_process(delta):
	if is_dead:
		return
	direction = _get_direction()
	velocity = _calculate_move_velocity(velocity, direction, speed)
	take_quest()
	_manage_animations()
	move_and_slide(velocity, Vector2.UP)

func _manage_animations():
	
	if direction.x > 0:
		$AnimatedSprite.flip_h = false
		$Range.position.x = 11.297
	elif direction.x < 0:
		$AnimatedSprite.flip_h = true
		$Range.position.x = -11.297

	if can_attack():
		state_machine.travel("attack")
		return

	if can_run():
		state_machine.travel("run")
		return

	if is_idle():
		state_machine.travel("idle")

func can_run():
	return _get_direction().x != 0 && on_floor

func is_idle():
	return on_floor && !attacking

func _attack():
	for body in $Range.get_overlapping_bodies():
		if  "Node2D" in body.name:
			body.OnTakeDamage()

func can_attack():
	return Input.is_action_pressed("attack") && on_floor
	
func set_attacking_to_true():
	attacking = true

func set_attacking_to_false():
	if Input.is_action_pressed("attack"):
		return 
	attacking = false
	
func take_damage(dmg):
	$Camera2D/HUD/TextureProgress.value -= dmg
	var effect = hit_particles_scn.instance()
	effect.get_node(".").set_emitting(true)
	get_tree().get_root().add_child(effect)
	
	effect.global_position.x = global_position.x
	effect.global_position.y = global_position.y
	if $Camera2D/HUD/TextureProgress.value <= 0:
		var explosion = explosion_scn.instance()
		get_tree().get_root().add_child(explosion)
		explosion.global_position.x = global_position.x
		explosion.global_position.y = global_position.y
		explosion.play("explode")
		$AnimatedSprite.visible = false
		$Hitbox.set_deferred("monitorable",false)
		$Hitbox.set_deferred("monitoring",false)
		is_dead = true

		

func take_quest():
	if position.x < -90:
		$Camera2D/HUD/RichTextLabel.visible = true
		if Input.is_action_pressed("interact"):
			quest_taken = true
		return
	if !quest_taken:
		$Camera2D/HUD/RichTextLabel.visible = false
		return
	else:
		$Camera2D/HUD/RichTextLabel.text = "Kill 10 mobs: " + str(Globals.kills) + " of 10"
		if Globals.kills >= 10:
			$Camera2D/HUD/RichTextLabel.text = "Quest Completed."

func _on_Area2D_body_entered(body):
	if body.name == "gameLevels":
		on_floor = true


func _on_Hitbox_body_entered(body):
	if "chest" in body.name:
		take_damage(1000)
	if "Node2D" in body.name:
		take_damage(10)
