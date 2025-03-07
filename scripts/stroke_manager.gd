extends Node2D

# for strokes refer to Manager.strokes


#list structure : [  - storing multiple dictionaries with stroke data 
	#{
	#stroke_points : []
	#stroke_color : PackedColorArray()
	#stroke_width : adjusted width at that time
	#}
#]


var current_stroke = [] # stores the current stroke points 
var previous_mouse_pos : Vector2 = Vector2.ZERO # just to check if mouse is at a new position
@onready var camera: Camera2D = $"../Camera2D"

var current_stroke_color = PackedColorArray() 

func _process(_delta: float) -> void:
	if(Manager.brush_type != "None"):
		handleDrawing()

func handleDrawing():
	var start_pos : Vector2
	
	if Input.is_action_just_pressed("click"): # started registering a new stroke 
		current_stroke = [] # empty it out for a new stroke 
		var mouse_pos = camera.get_global_mouse_position()
		# it should be taken in reference to camera 
		start_pos = mouse_pos
		print("new start pos : ", start_pos)
		current_stroke.append(mouse_pos) 
		previous_mouse_pos = mouse_pos
	
		
	if Input.is_action_pressed("click") : # registering all points in stroke 
		var current_mouse_pos = camera.get_global_mouse_position()
		if(current_mouse_pos != previous_mouse_pos):
			current_stroke.append(current_mouse_pos)
			previous_mouse_pos = current_mouse_pos
			Manager.update_canvas()
			
	
	if Input.is_action_just_released("click"): # pushing it in storage
		
		if current_stroke.size() > 1 : 
			var picked_color = Color(Manager.picked_color) # creating a copy , no direct reference
			var stroke_width = Manager.brush_size 
			picked_color.a = Manager.brush_transparency 
			
			# now applying brush filters : 
			#"Spiky Lines", "Bad Brush" , "Smooth" , "Ultra-Smooth", "None"
			var brush_effect = Manager.brush_effect_type
			#print(current_stroke.size())
			current_stroke = PackedVector2Array(current_stroke)
			#print(current_stroke.size())
			#print()
			
			var final_points  
			#print(brush_effect)
			if(brush_effect == "None"):
				final_points = current_stroke 
				#print("none")
				
			elif(brush_effect == "Spiky Lines"):
				final_points = get_quadratic_bezier_points(current_stroke , 15)
				#print("Spiky Lines")
				
			elif(brush_effect == "Bad Brush"):
				final_points = get_quadratic_bezier_points(current_stroke , 1)
				#print("Bad Brush")
				
			elif(brush_effect == "Smooth"):
				final_points = get_catmull_rom_points(current_stroke , 10)
				#print("Smooth")
				
			elif (brush_effect == "Ultra-Smooth"):
				final_points = get_catmull_rom_points(current_stroke, 100)
				#print("Ultra-Smooth")
				
			
			#var smoothed_points = get_quadratic_bezier_points(current_stroke, curve_segments)
			Manager.total_points_stored += final_points.size()
			var new_stroke = {
				"stroke_points" : final_points, # we don't need any references of it
				"stroke_color" : PackedColorArray([picked_color]),
				"stroke_width" :  stroke_width / camera.zoom.x,
			}
			
			Manager.strokes.append(new_stroke)
			Manager.orderOfDrawing.append("Stroke")
			Manager.update_canvas()



func _draw() -> void:
	Manager.queue_redraw_calls += 1
	
	for stroke in Manager.strokes: # drawing all strokes in storage 
		draw_polyline_colors(stroke["stroke_points"], stroke["stroke_color"] , stroke["stroke_width"], true)
	
	
	# drawing the current stroke
	if current_stroke.size() > 1 : 
		var picked_color = Color(Manager.picked_color) # creating a copy , no direct reference
		var stroke_width = Manager.brush_size 
		picked_color.a = Manager.brush_transparency 
			
		# now applying brush filters : 
		#"Spiky Lines", "Bad Brush" , "Smooth" , "Ultra-Smooth", "None"
		var brush_effect = Manager.brush_effect_type
		current_stroke = PackedVector2Array(current_stroke)
			
		var final_points  
		if(brush_effect == "None"):
			final_points = current_stroke
		elif(brush_effect == "Spiky Lines"):
			final_points = get_quadratic_bezier_points(current_stroke , 10)
		elif(brush_effect == "Bad Brush"):
			final_points = get_quadratic_bezier_points(current_stroke , 1)
		elif(brush_effect == "Smooth"):
			final_points = get_catmull_rom_points(current_stroke , 20)
		elif (brush_effect == "Ultra-Smooth"):
			final_points = get_catmull_rom_points(current_stroke, 200)
		
		draw_polyline_colors(final_points, PackedColorArray([picked_color]), stroke_width / camera.zoom.x, true)
	

# it will generate spike lines at 20 segments 
# it will generate bad brush at 1 segment 
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

# smooth at 20 segments
# ultra smooth at 200 segments but slower to process.
func get_catmull_rom_points(points: PackedVector2Array, segments: int ) -> PackedVector2Array:
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

# this is not used anywhere at present, but it provides more fine grained control.
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
