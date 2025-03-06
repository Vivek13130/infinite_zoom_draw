extends Node2D

# added optimizations but removed them . 

# responsiblity : 
# registering new stroke 
# managing old strokes
# hashing and rendering only visible strokes 
# defining grid 

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


var current_stroke = [] # stores the current stroke points 
var previous_mouse_pos : Vector2 = Vector2.ZERO # just to check if mouse is at a new position
@onready var camera: Camera2D = $"../Camera2D"

@export var base_stroke_width = 2.0 
var current_stroke_color = PackedColorArray()


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	handleDrawing()


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
			
			
			#print("stroke no : ", strokes.size() + 1)
			#print("size : " , current_stroke.size())
			#print(current_stroke)
			#print()
			
			var new_stroke = {
				"stroke_points" : current_stroke.duplicate(), # we don't need any references of it
				"stroke_color" : current_stroke_color,
				"stroke_width" :  base_stroke_width / camera.zoom.x,
			}
			
			strokes.append(new_stroke)
			update_canvas()
			
			
			#THIS COMMENTED IS CODE IS RELATED TO OPTIMIZATIONS : 
			
			## calculate the grid cell from this start pos
			#var respective_grid_row = int(floor(float(start_pos.y) / grid_size.y))
			#var respective_grid_col = int(floor(float(start_pos.x) / grid_size.x))
			#
			## generate a key based on grid cell position of this stroke
			## cell(1 ,3) = 1_3
			#var grid_cell_key = str(respective_grid_row) + "_" + str(respective_grid_col) 
			#print("grid cell key for this stroke : " , grid_cell_key)
			#
			#var bounding_box_top_left : Vector2 = Vector2.INF # stores min x and min y value among all points in stroke
			#var bounding_box_bottom_right : Vector2 = Vector2(-INF , -INF) # stores max x and max y value among all points in stroke
			#
			#for point in current_stroke : 
				#bounding_box_top_left.x = min(point.x , bounding_box_top_left.x)
				#bounding_box_top_left.y = min(point.y , bounding_box_top_left.y)
				#bounding_box_bottom_right.x = max(point.x , bounding_box_bottom_right.x)
				#bounding_box_bottom_right.y = max(point.y , bounding_box_bottom_right.y)
			#
			#
			#var new_stroke = {
				#"stroke_points" : current_stroke.duplicate(), # we don't need any references of it
				#"stroke_color" : current_stroke_color,
				#"stroke_width" :  base_stroke_width / camera.zoom.x,
				#"bounding_rect" : Rect2(bounding_box_top_left, abs(bounding_box_bottom_right - bounding_box_top_left))
			#}
			#
			#print("new stroke registered in : ", grid_cell_key)
			#print(new_stroke["bounding_rect"])
			
			#if(strokes.has(grid_cell_key)):
				#strokes[grid_cell_key].append(new_stroke)
			#else:
				#strokes[grid_cell_key] = [] # empty list for storing all strokes 
				#strokes[grid_cell_key].append(new_stroke)
			


func update_canvas():
	queue_redraw()

func _draw() -> void:
	Manager.queue_redraw_calls += 1
	
	# drawing the current stroke
	if current_stroke.size() > 1 : 
		draw_polyline_colors(current_stroke, PackedColorArray([Color.YELLOW]) , base_stroke_width / camera.zoom.x, true)
	
	for stroke in strokes:
		draw_polyline_colors(stroke["stroke_points"], stroke["stroke_color"] , stroke["stroke_width"], true)
		
	
	## get the camera rect : 
	#var camera_rect: Rect2 = Rect2( 
		#camera.get_position() - get_viewport_rect().size / 2 / camera.zoom, 
		#get_viewport_rect().size / camera.zoom )
	#
	#draw_rect(camera_rect, Color.YELLOW, false, 2)	
	
	#drawing registered strokes : 
	#for grid_cell in strokes:
		#var underscore = true
		#var row_col = grid_cell.split("_")
		#
		#var cell_rect = Rect2( Vector2(int(row_col[0]) * grid_size.y , int(row_col[1]) * grid_size.x), grid_size)
		#draw_rect(cell_rect, Color.BLUE , false , 2)
		#
		## this cell is completely inside camera : 
		#if camera_rect.encloses(cell_rect): 
			## render all strokes 
			#for stroke in strokes[grid_cell]:
			## now stroke is a dictionary : stroke_points, stroke_color, stroke_width, bounding_rect
				#draw_polyline_colors(stroke["stroke_points"], stroke["stroke_color"] , stroke["stroke_width"], true)
				#draw_rect(stroke["bounding_rect"], Color.GREEN, false)
		#
		## this stroke is partially overlapping camera
		#elif camera_rect.intersects(cell_rect):
			## use bounding box and render only overlapping strokes 
			#for stroke in strokes[grid_cell]:
				#if camera_rect.intersects(stroke["bounding_rect"]):
					#draw_polyline_colors(stroke["stroke_points"], stroke["stroke_color"] , stroke["stroke_width"], true)
				#else:
					#draw_polyline_colors(stroke["stroke_points"], PackedColorArray([Color(1,0,0)]) , stroke["stroke_width"], true)
		#
		## this cell is completely outside the camera 
		#else:
			#for stroke in strokes[grid_cell]:
				#draw_polyline_colors(stroke["stroke_points"], PackedColorArray([Color(1,0,0)]) , stroke["stroke_width"], true)
				
		
		# check if this cell is in camera rect or not 
		# if yes : check if it's fully in or partially in
		# if partially , use the bounding box thing 
		# otherwise render all strokes in it 
		#draw_polyline_colors(stroke_dict["stroke_points"], stroke_dict["stroke_color"] , stroke_dict["stroke_width"], true)
	
