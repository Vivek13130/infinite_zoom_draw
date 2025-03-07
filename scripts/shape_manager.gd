extends Node2D
@onready var camera : Camera2D = $"../Camera2D"

var current_shape : Dictionary = {}
var shape_recording : bool = false

func _process(_delta: float) -> void:
	if Manager.shape_type != "None":
		handleShapesDrawing()

func handleShapesDrawing():
	if Input.is_action_just_pressed("click") and Manager.shape_effect_type != "None":
		var random_fill = false
		var random_colors = false 
		if Manager.shape_effect_type == "Sprinkler-2":
			random_fill = true 
		if Manager.shape_effect_type == "Sprinkler-3":
			random_fill = true
			random_colors = true
		
		sprinkle_shapes(camera.get_global_mouse_position() , Manager.shape_type, random_fill , random_colors)
	
	if Input.is_action_just_pressed("click") and Manager.shape_effect_type == "None":
		var mouse_pos = camera.get_global_mouse_position()
		var picked_color = Color(Manager.picked_color)
		picked_color.a = Manager.brush_transparency
		var stroke_width = Manager.brush_size / camera.zoom.x
		shape_recording = true 
		
		current_shape = {
			"shape_type": Manager.shape_type,
			"start_pos": mouse_pos,
			"end_pos": mouse_pos,
			"stroke_color": PackedColorArray([picked_color]),
			"stroke_width": stroke_width,
			"shape_filled": false
		}
		print("current shape started")

	if Input.is_action_pressed("click") and shape_recording:
		current_shape["end_pos"] = camera.get_global_mouse_position()
		Manager.update_canvas()

	if Input.is_action_just_released("click") and shape_recording:
		shape_recording = false
		current_shape["end_pos"] = camera.get_global_mouse_position()
		print(current_shape)
		print(current_shape.size())
		Manager.shapes.append(current_shape.duplicate())
		Manager.orderOfDrawing.append("Shape")

		#current_shape = {}
		Manager.update_canvas()

func _draw() -> void:
	for new_shape in Manager.shapes:
		draw_shape(new_shape)
		
	if current_shape.size() != 0:
		draw_shape(current_shape)

func draw_shape(new_shape: Dictionary) -> void:
	var shape_type: String = new_shape["shape_type"]
	var start_pos: Vector2 = new_shape["start_pos"]
	var end_pos: Vector2 = new_shape["end_pos"]
	var stroke_color: Color = new_shape["stroke_color"][0]
	var stroke_width: float = new_shape["stroke_width"]
	var shape_filled : bool = new_shape["shape_filled"]
	
	match shape_type:
		"Line":
			draw_line(start_pos, end_pos, stroke_color, stroke_width, true)
		
		"Rectangle":
			var rect: Rect2 = Rect2(start_pos, end_pos - start_pos)
			draw_rect(rect, stroke_color, shape_filled, stroke_width)
		
		"Square":
			var size: float = min(abs(end_pos.x - start_pos.x), abs(end_pos.y - start_pos.y))
			var rect: Rect2 = Rect2(start_pos, Vector2(size, size))
			draw_rect(rect, stroke_color, shape_filled, stroke_width)
		
		"Circle":
			var center: Vector2 = start_pos
			var radius: float = start_pos.distance_to(end_pos)
			if(shape_filled):
				stroke_width = -1.0 # to make it filled 
			draw_circle(center, radius, stroke_color, shape_filled , stroke_width , true)
		
		


func sprinkle_shapes(center: Vector2, shape_type: String, random_fill , random_colors):
	var picked_color = Color(Manager.picked_color)
	
	
	picked_color.a = Manager.brush_transparency

	var zoom_factor = camera.zoom.x
	var stroke_width = Manager.brush_size / zoom_factor

	for i in range(Manager.shape_spawn_density):
		if(random_colors):
			picked_color = Color(Manager.pickable_colors[randi_range(0 , Manager.pickable_colors.size()-1)])
		
		var angle = randf() * TAU 
		var distance = randf() * Manager.shape_spawn_radius * 10 / zoom_factor 
		var pos = center + Vector2(cos(angle), sin(angle)) * distance
		
		var size = randi_range(5, 30) / zoom_factor 
		
		var shape_filled = false 
		if(random_fill):
			if(randf() < 0.5):
				shape_filled = true
		
		var shape = {
			"shape_type": shape_type,
			"start_pos": pos,
			"end_pos": pos + Vector2(size, size),
			"stroke_color": PackedColorArray([picked_color]),
			"stroke_width": stroke_width,
			"shape_filled": shape_filled
		}
		
		if shape_type == "Line":
			var line_angle = randf() * TAU 
			shape["end_pos"] = pos + Vector2(cos(line_angle), sin(line_angle)) * size
		
		Manager.shapes.append(shape)
	Manager.update_canvas()
