extends KinematicBody2D

const grav = 200
const speed = Vector2(70,50)
var velocity = Vector2.ZERO
var Direction = Vector2.ZERO

var left
var right
var setDir = false
var health = 100

const hit_particles_scn = preload("res://hit_particles.tscn")
const explosion_scn = preload("res://explosion.tscn")

var isRaging = false

func _ready():
	#health = ceil(Globals.Score / 100)
	#$ProgressBar.max_value = health
	$TextureProgress.value = health
	
func _physics_process(delta):
	CheckForObsticles()
	CheckIfOnAnEdge()
	PlayAnimations()
	velocity = _calculate_move_velocity(velocity, Direction,speed)
	move_and_slide(velocity)
	
func OnTakeDamage():
	health -= 50
	$TextureProgress.value -= 50
	var effect = hit_particles_scn.instance()
	effect.get_node(".").set_emitting(true)
	effect.global_position.x = global_position.x
	effect.global_position.y = global_position.y
	get_tree().get_root().add_child(effect)

	if health <= 0:
		var explosion = explosion_scn.instance()
		explosion.global_position.x = global_position.x
		explosion.global_position.y = global_position.y
		get_tree().get_root().add_child(explosion)
		explosion.play("explode")
		#Globals.Score += 15
		queue_free()
	
func _calculate_move_velocity(
	linear_velocity: Vector2,
	directions: Vector2,
	speedy:Vector2) -> Vector2:
	var new_velocity = linear_velocity
	new_velocity.x = speedy.x * directions.x
	new_velocity.y += grav * get_physics_process_delta_time()
	
	for body in $Vision.get_overlapping_bodies():
		if body.name == "KinematicBody2D":
			isRaging = true
	if isRaging:
		new_velocity.x = 2.5* speedy.x * directions.x
	return new_velocity

func PlayAnimations():
	if Direction.x == 1:
		$AnimatedSprite.flip_h = true
		$Vision.position.x = 109.75
	else:
		$AnimatedSprite.flip_h = false
		$Vision.position.x = -109.75
		
		
	if Direction.x != 0 and (abs(velocity.x) > 1 and abs(velocity.x) < speed.y * 2):
		$AnimationPlayer.play("walk")
		return
	if Direction.x != 0 and abs(velocity.x) > speed.y * 2.5:
		$AnimationPlayer.play("run")
		return
	$AnimationPlayer.play("idle")
	

func CheckForObsticles():
	for body in $ObsticleDetectorRight.get_overlapping_bodies():
		if body.name == "gameLevels" or "Enemy" in body.name:
			for b in $GroundCheckLeft.get_overlapping_bodies():	
				if b.name == "player":
					#Direction.x = 0
					return
			for b in $GroundCheckRight.get_overlapping_bodies():	
				if b.name == "player":
					#Direction.x = 0
					return
			if $GroundCheckLeft.get_overlapping_bodies().size() < 1:
				Direction.x = 0
				return
			Direction.x = -1
			return
			
			
	for body in $ObsticleDetectorLeft.get_overlapping_bodies():
		if (body.name == "gameLevels" or "Enemy" in body.name):
			for b in $GroundCheckLeft.get_overlapping_bodies():	
				if b.name == "player":
					#Direction.x = 0
					return
			for b in $GroundCheckRight.get_overlapping_bodies():	
				if b.name == "player":
					#Direction.x = 0
					return
			if $GroundCheckRight.get_overlapping_bodies().size() < 1:
				Direction.x = 0
				return
			Direction.x = 1
			return


func CheckIfOnAnEdge():
	for body in $GroundCheckLeft.get_overlapping_bodies():
		if ("Enemy" in body.name || body.name == "player"):
			return

	for body in $GroundCheckRight.get_overlapping_bodies():
		if ("Enemy" in body.name || body.name == "player"):
			return
			
	if $Area2D.get_overlapping_bodies().size() > 1:
		if $GroundCheckLeft.get_overlapping_bodies().size() >= 1 && $GroundCheckRight.get_overlapping_bodies().size() >= 1:
			if !setDir:
				if $ObsticleDetectorRight.get_overlapping_bodies().size() > 1:
					Direction.x = -1
					setDir = true
					return
				if $ObsticleDetectorLeft.get_overlapping_bodies().size() > 1:
					Direction.x = 1
					setDir = true
					return
				Direction.x = -1 if rand_range(0,1) < 0.5 else 1
				setDir = true
				return
			
		if $GroundCheckLeft.get_overlapping_bodies().size() < 1: 
			Direction.x = 1

		if $GroundCheckRight.get_overlapping_bodies().size() < 1:
			Direction.x = -1

		if $GroundCheckLeft.get_overlapping_bodies().size() < 1 and $GroundCheckRight.get_overlapping_bodies().size() < 1:
			Direction.x = 0

		if ($GroundCheckLeft.get_overlapping_bodies().size() < 1 and $ObsticleDetectorRight.get_overlapping_bodies().size() > 0) or ($GroundCheckRight.get_overlapping_bodies().size() < 1 and $ObsticleDetectorLeft.get_overlapping_bodies().size() > 0):
			Direction.x = 0


func _on_HitBox_body_entered(body):
	if body.name == "player":
		Globals.PlayerInRange = true


func _on_HitBox_body_exited(body):
	if (body.name == "player"):
		Globals.PlayerInRange = false
