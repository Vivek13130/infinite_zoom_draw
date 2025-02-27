extends Node2D
@onready var camera: Camera2D = $Camera2D

var strokes = [] # stores all completed strokes with other info as well 
# it is a list of dictionaries

# dict structure : 
#{
	#stroke_points : []
	#stroke_color : PackedColorArray()
	#stroke_width : adjusted width at that time
#}

# each element is another array of points 

var current_stroke = [] # stores the current stroke points 
var previous_mouse_pos : Vector2 = Vector2.ZERO # just to check if mouse is at a new position

@export var base_stroke_width = 2.0 
var current_stroke_color = PackedColorArray()


func _ready() -> void:
	# at present we are only using one color here.
	current_stroke_color.fill(Color.GREEN_YELLOW)


func _process(delta: float) -> void:
	handleDrawing()


func handleDrawing():
	if Input.is_action_just_pressed("click"): # started registering a new stroke 
		current_stroke = [] # empty it out for a new stroke 
		var mouse_pos = camera.get_global_mouse_position()
		current_stroke.append(mouse_pos) 
		previous_mouse_pos = mouse_pos
		# it should be taken in reference to camera 
		
	
		
	if Input.is_action_pressed("click") : # registering all points in stroke 
		var current_mouse_pos = camera.get_global_mouse_position()
		if(current_mouse_pos != previous_mouse_pos):
			current_stroke.append(current_mouse_pos)
			previous_mouse_pos = current_mouse_pos
			
	
	if Input.is_action_just_released("click"): # pushing it in storage
		if current_stroke.size() > 1 : 
			
			print("stroke no : ", strokes.size() + 1)
			print("size : " , current_stroke.size())
			print(current_stroke)
			print()
			
			var new_stroke = {
				"stroke_points" : current_stroke.duplicate(), # we don't need any references of it
				"stroke_color" : current_stroke_color,
				"stroke_width" :  base_stroke_width / camera.zoom.x
			}
			
			strokes.append(new_stroke)
			update_canvas()
			
		current_stroke = []


func update_canvas():
	queue_redraw()

func _draw() -> void:
	
	#drawing completed strokes : 
	for stroke_dict in strokes:
		#print(stroke_dict)
		draw_polyline_colors(stroke_dict["stroke_points"], stroke_dict["stroke_color"] , stroke_dict["stroke_width"], true)
	
