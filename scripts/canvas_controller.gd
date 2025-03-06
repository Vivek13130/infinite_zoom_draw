extends Node2D






#responsibility : 
# draw grid for debugging : 


#THIS COMMENTED CODE WAS RELATED TO DRAWING GRID ON SCREEN , BUT WE DON'T NEED THIS 
# Grid settings
#var grid_size: Vector2 = Manager.grid_size # Size of each grid cell
#var line_color: Color = Color(0.5, 0, 0, 0.5) # Light red with transparency
#var line_width: float = 1.0

# reference to the camera to adjust grid with zoom/pan
#@onready var camera: Camera2D = $Camera2D

#func _process(delta: float) -> void:
	#queue_redraw() # continuously redraw the grid
#
#func _draw() -> void:
	#if not camera:
		#return
	#
	## Get the visible area of the camera
	#var screen_rect: Rect2 = Rect2(camera.get_position() - get_viewport_rect().size / 2 / camera.zoom, get_viewport_rect().size / camera.zoom)
	#
	## Calculate grid bounds
	#var start_x: float = floor(screen_rect.position.x / grid_size.x) * grid_size.x
	#var end_x: float = floor((screen_rect.position.x + screen_rect.size.x) / grid_size.x) * grid_size.x
	#var start_y: float = floor(screen_rect.position.y / grid_size.y) * grid_size.y
	#var end_y: float = floor((screen_rect.position.y + screen_rect.size.y) / grid_size.y) * grid_size.y
#
	## Draw vertical lines
	#for x in range(start_x, end_x, grid_size.x):
		#draw_line(Vector2(x, start_y), Vector2(x, end_y), line_color, line_width)
	#
	## Draw horizontal lines
	#for y in range(start_y, end_y, grid_size.y):
		#draw_line(Vector2(start_x, y), Vector2(end_x, y), line_color, line_width)
