extends Sprite


func _ready():
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y

	var scale1 = viewportWidth / texture.get_size().x

# Optional: Center the sprite, required only if the sprite's Offset>Centered checkbox is set
	position = Vector2(viewportWidth/2, viewportHeight/2)

# Set same scale value horizontally/vertically to maintain aspect ratio
# If however you don't want to maintain aspect ratio, simply set different
# scale along x and y
	scale = Vector2(scale1, scale1)
