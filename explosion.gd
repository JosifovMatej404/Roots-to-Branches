extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimatedSprite_animation_finished():
	queue_free()
	var progress = get_node("/root/Game/player/Camera2D/HUD/TextureProgress")
	if progress.value <= 0:
		var youdied = get_node("/root/Game/player/Camera2D/HUD/YouDied")	
		youdied.visible = true
