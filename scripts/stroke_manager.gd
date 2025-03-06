extends Node2D


var grid_size = Manager.grid_size # grid size in px 

var strokes : Array = [] # stores all completed strokes with other info as well 
# it is a list of dictionaries

#list structure : [  - storing multiple dictionaries with stroke data 
	#{
	#stroke_points : []
	#stroke_color : PackedColorArray()
	#stroke_width : adjusted width at that time
	#}
#]

var curve_segments = 10

var current_stroke = [] # stores the current stroke points 
var previous_mouse_pos : Vector2 = Vector2.ZERO # just to check if mouse is at a new position
@onready var camera: Camera2D = $"../Camera2D"

@export var pencil_base_stroke_width = 20.0 
@export var highlighter_base_stroke_width = 30.0
@export var highlighter_color_transparency = 0.2

var current_stroke_color = PackedColorArray() 




func _process(delta: float) -> void:
	if(Manager.brush_type != "None"):
		handleDrawing()
	
	if(Manager.shape_type != "None"):
		handleShapes()


func handleDrawing():
	var start_pos : Vector2
	
	if Input.is_action_just_pressed("click"): # started registering a new stroke 
		current_stroke = [] # empty it out for a new stroke 
		var mouse_pos = camera.get_global_mouse_position()
		start_pos = mouse_pos
		#print("new start pos : ", start_pos)
		current_stroke.append(mouse_pos) 
		previous_mouse_pos = mouse_pos
		# it should be taken in reference to camera 
	
		
	if Input.is_action_pressed("click") : # registering all points in stroke 
		var current_mouse_pos = camera.get_global_mouse_position()
		if(current_mouse_pos != previous_mouse_pos):
			current_stroke.append(current_mouse_pos)
			previous_mouse_pos = current_mouse_pos
			queue_redraw()
			
	
	if Input.is_action_just_released("click"): # pushing it in storage
		
		if current_stroke.size() > 1 : 
			var picked_color = Color(Manager.picked_color) # creating a copy , no direct reference
			var stroke_width
			
			if(Manager.brush_type == "Pencil"):
				stroke_width = pencil_base_stroke_width
				
			elif(Manager.brush_type == "Highlighter"):
				picked_color.a = highlighter_color_transparency
				stroke_width = highlighter_base_stroke_width
				print(picked_color)
			
			#var smoothed_points = get_quadratic_bezier_points(current_stroke, curve_segments)
			var smoothed_points = get_catmull_rom_points(current_stroke, curve_segments)
			
			var new_stroke = {
				"stroke_points" : smoothed_points, # we don't need any references of it
				"stroke_color" : PackedColorArray([picked_color]),
				"stroke_width" :  stroke_width / camera.zoom.x,
			}
			
			strokes.append(new_stroke)
			queue_redraw()


func handleShapes() -> void : 
	pass


func _draw() -> void:
	Manager.queue_redraw_calls += 1
	
	for stroke in strokes: # drawing all strokes in storage 
		draw_polyline_colors(stroke["stroke_points"], stroke["stroke_color"] , stroke["stroke_width"], true)
	
	
	# drawing the current stroke
	if current_stroke.size() > 1 : 
		var stroke_width
		var picked_color = Color(Manager.picked_color)
		
		if(Manager.brush_type == "Pencil"):
			stroke_width = pencil_base_stroke_width
			
		elif(Manager.brush_type == "Highlighter"):
			stroke_width = highlighter_base_stroke_width
			picked_color.a = highlighter_color_transparency
		
		#var smoothed_points = get_quadratic_bezier_points(current_stroke, curve_segments)
		var smoothed_points = get_catmull_rom_points(current_stroke, curve_segments)
		draw_polyline(smoothed_points, picked_color, stroke_width / camera.zoom.x, true)
		#draw_polyline_colors(current_stroke, PackedColorArray([picked_color]) , stroke_width / camera.zoom.x, true)
	
	


func get_quadratic_bezier_points(points: PackedVector2Array, segments : int) -> PackedVector2Array:
	var bezier_points = PackedVector2Array()
	for i in range(1, points.size() - 1):
		var p0 = points[i - 1]
		var p1 = points[i]
		var p2 = points[i + 1]

		for t in range(segments + 1):
			var t_norm = float(t) / float(segments)
			var a = p0.lerp(p1, t_norm)
			var b = p1.lerp(p2, t_norm)
			var point = a.lerp(b, t_norm)
			bezier_points.append(point)
	return bezier_points


func get_catmull_rom_points(points: PackedVector2Array, segments: int ) -> PackedVector2Array:
	var smoothed_points = PackedVector2Array()
	for i in range(points.size() - 1):
		var p0 = points[max(i - 1, 0)]
		var p1 = points[i]
		var p2 = points[i + 1]
		var p3 = points[min(i + 2, points.size() - 1)]

		for t in range(segments + 1):
			var t_norm = float(t) / float(segments)
			var t2 = t_norm * t_norm
			var t3 = t2 * t_norm

			var x = 0.5 * (
				2.0 * p1.x +
				(-p0.x + p2.x) * t_norm +
				(2.0 * p0.x - 5.0 * p1.x + 4.0 * p2.x - p3.x) * t2 +
				(-p0.x + 3.0 * p1.x - 3.0 * p2.x + p3.x) * t3
			)

			var y = 0.5 * (
				2.0 * p1.y +
				(-p0.y + p2.y) * t_norm +
				(2.0 * p0.y - 5.0 * p1.y + 4.0 * p2.y - p3.y) * t2 +
				(-p0.y + 3.0 * p1.y - 3.0 * p2.y + p3.y) * t3
			)

			smoothed_points.append(Vector2(x, y))
	return smoothed_points


func get_catmull_rom_points_improved(points: PackedVector2Array, segments: int ) -> PackedVector2Array:
	var smoothed_points = PackedVector2Array()
	
	for i in range(points.size() - 1):
		var p0 = points[max(i - 1, 0)]
		var p1 = points[i]
		var p2 = points[min(i + 1, points.size() - 1)]
		var p3 = points[min(i + 2, points.size() - 1)]

		for t in range(segments + 1):
			var t_norm = float(t) / float(segments)
			var t2 = t_norm * t_norm
			var t3 = t2 * t_norm

			var x = 0.5 * (
				2.0 * p1.x +
				(-p0.x + p2.x) * t_norm +
				(2.0 * p0.x - 5.0 * p1.x + 4.0 * p2.x - p3.x) * t2 +
				(-p0.x + 3.0 * p1.x - 3.0 * p2.x + p3.x) * t3
			)

			var y = 0.5 * (
				2.0 * p1.y +
				(-p0.y + p2.y) * t_norm +
				(2.0 * p0.y - 5.0 * p1.y + 4.0 * p2.y - p3.y) * t2 +
				(-p0.y + 3.0 * p1.y - 3.0 * p2.y + p3.y) * t3
			)

			smoothed_points.append(Vector2(x, y))
	
	return smoothed_points


func get_cubic_bezier_points(points: PackedVector2Array, segments: int) -> PackedVector2Array:
	var bezier_points = PackedVector2Array()

	for i in range(points.size() - 3):
		var p0 = points[i]
		var p1 = points[i + 1]
		var p2 = points[i + 2]
		var p3 = points[i + 3]

		for t in range(segments + 1):
			var t_norm = float(t) / float(segments)
			var t2 = t_norm * t_norm
			var t3 = t2 * t_norm

			var x = ((1 - t_norm) * (1 - t_norm) * (1 - t_norm) * p0.x + 
					3 * (1 - t_norm) * (1 - t_norm) * t_norm * p1.x +
					3 * (1 - t_norm) * t_norm * t_norm * p2.x + t3 * p3.x )

			var y = ((1 - t_norm) * (1 - t_norm) * (1 - t_norm) * p0.y +
					3 * (1 - t_norm) * (1 - t_norm) * t_norm * p1.y +
					3 * (1 - t_norm) * t_norm * t_norm * p2.y + t3 * p3.y)

			bezier_points.append(Vector2(x, y))
	
	return bezier_points
