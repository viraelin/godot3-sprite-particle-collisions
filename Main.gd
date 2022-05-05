extends Node2D

func _ready() -> void:
	_image_from_tiles()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		var pos: = get_global_mouse_position()
		_spawn_particles(pos)

func _spawn_particles(pos: Vector2) -> void:
	var particles: Particles2D = preload("res://Particles.tscn").instance()
	var collision: = load("res://tilemap-collision.png")
	
	var sprite: Sprite = $Sprite
	sprite.hide()
	
	var sprite_pos: = sprite.global_position
	
	var texture: = sprite.texture
	var size: = texture.get_size()
	
	var frame_size: = Vector2(size.x / sprite.hframes, size.y / sprite.vframes)
	var frame_pos: = Vector2(frame_size.x * sprite.frame_coords.x, frame_size.y * sprite.frame_coords.y)
	
	var width: = frame_size.x
	var height: = frame_size.y
	var amount: = width * height
	var extents: = Vector3(width/2, height/2, 0.0)
	
	var sprite_image: = texture.get_data()
	var frame_rect: = Rect2(frame_pos, frame_size)
	var frame_image: = sprite_image.get_rect(frame_rect)
	
	if sprite.flip_h:
		frame_image.flip_x()
	if sprite.flip_v:
		frame_image.flip_y()
	if sprite.scale.x == -1:
		frame_image.flip_x()
	if sprite.scale.y == -1:
		frame_image.flip_y()
		
	var frame_texture: = ImageTexture.new()
	var flags: = 0
	frame_texture.create_from_image(frame_image, flags)
	
	var direction: = pos.direction_to(sprite_pos)
	
	var duration: = 3.0
	particles.lifetime = duration
	particles.amount = amount
	particles.process_material.set_shader_param("direction", Vector3(direction.x, direction.y, 0.0))
	particles.process_material.set_shader_param("sprite", frame_texture)
	particles.process_material.set_shader_param("collision", collision)
	particles.process_material.set_shader_param("sprite_pos", -sprite_pos)
	particles.process_material.set_shader_param("emission_box_extents", extents)
	particles.position = sprite_pos
	particles.restart()
	add_child(particles)
	
	yield(get_tree().create_timer(duration), "timeout")
	particles.queue_free()
	
	sprite.show()

func _image_from_tiles():
	var tilemap: TileMap = $TileMap
	var used_rect: = tilemap.get_used_rect()
	var width: = used_rect.size.x
	var height: = used_rect.size.y
	
	var x_range: = range(used_rect.position.x, (used_rect.position.x + width))
	var y_range: = range(used_rect.position.y, (used_rect.position.y + height))
	
	var image: = Image.new()
	image.create(width, height, false, Image.FORMAT_RGB8)
	image.lock()
	
	var xi: = 0
	var yi: = 0
	for y in y_range:
		for x in x_range:
			var color: Color
			var cell_id: = tilemap.get_cell(x, y)
			if cell_id == TileMap.INVALID_CELL:
				color = Color.white
			else:
				color = Color.black
			image.set_pixel(xi, yi, color)
			xi += 1
		xi = 0
		yi += 1
	image.unlock()
	
	image.resize(width * tilemap.cell_size.x, height * tilemap.cell_size.y, Image.INTERPOLATE_NEAREST)
	image.save_png("res://tilemap-collision.png")

