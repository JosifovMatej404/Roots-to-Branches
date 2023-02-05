extends KinematicBody2D

const grav = 0
const speed = Vector2(70,50)
var velocity = Vector2.ZERO
var Direction = Vector2.ZERO
var startX
var startY

var left
var right
var setDir = false
var health = 100

const hit_particles_scn = preload("res://hit_particles.tscn")
const explosion_scn = preload("res://explosion.tscn")


func _ready():
	startX = global_position.x
	startY = global_position.y
	#health = ceil(Globals.Score / 100)
	#$ProgressBar.max_value = health
	$TextureProgress.value = health
	Direction.x = 1
	Direction.y = 1
	
func _physics_process(delta):
	PlayAnimations()
	
	if (global_position.x > startX + 100 or global_position.x < startX - 100):
		Direction.x *= -1

	velocity = _calculate_move_velocity(velocity, Direction,speed)
	move_and_slide(velocity)
	
func OnTakeDamage():
	health -= 100
	$TextureProgress.value -= 100
	var effect = hit_particles_scn.instance()
	effect.get_node(".").set_emitting(true)
	get_tree().get_root().add_child(effect)
	
	effect.global_position.x = global_position.x
	effect.global_position.y = global_position.y
	if health <= 0:
		var explosion = explosion_scn.instance()
		get_tree().get_root().add_child(explosion)
		explosion.global_position.x = global_position.x
		explosion.global_position.y = global_position.y

		explosion.play("explode")
		#Globals.Score += 15
		queue_free()
	

func _calculate_move_velocity(
	linear_velocity: Vector2,
	directions: Vector2,
	speedy:Vector2) -> Vector2:
	var new_velocity = linear_velocity
	new_velocity.x = speedy.x * directions.x
	new_velocity.y += 0
	
	return new_velocity

func PlayAnimations():
	if Direction.x == 1:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false

	$AnimationPlayer.play("fly")
	

func _on_HitBox_body_entered(body):
	if body.name == "player":
		Globals.PlayerInRange = true


func _on_HitBox_body_exited(body):
	if (body.name == "player"):
		Globals.PlayerInRange = false
