extends Node

# this is a global script. it will contain all constants and all 

const grid_size = Vector2(40, 40)
var queue_redraw_calls = 0 

var picked_color : Color = Color.WHITE
var new_picked_color : Color = Color.WHITE

const pickable_colors = [
	"#FF0000", "#FF7F00", "#FFFF00", "#7FFF00", "#00FF00", "#00FF7F",
	"#00FFFF", "#007FFF", "#0000FF", "#7F00FF", "#FF00FF", "#FF007F",
	"#FF3399", "#000000", "#FFFFFF", "#CC99FF", "#9966FF", "#6633FF",
	"#3366FF", "#33CCFF", "#33FFCC", "#33FF66", "#66FF33", "#99FF33"
]

var zoom_level : Vector2


# these will contain what is selected . 
var brush_type 
var brush_size 
var brush_transparency
var brush_effect_type 

var shape_type 
var shape_effect_type  
var shape_spawn_radius
var shape_spawn_density


#last element should be none in all of these 
const brushes_available = ["Pencil", "Highlighter", "None"]
const shapes_available = ["Triangle", "Square", "Line", "Circle", "Rectangle", "None"]
const shape_effects_available = ["Sprinkler-1", "Sprinkler-2", "Sprinkler-3" , "None"  ]
const brush_effect_available = ["Spiky Lines", "Bad Brush" , "Smooth" , "Ultra-Smooth", "None"]


var strokes : Array = [] # stores all the strokes 
var shapes  : Array = [] # stores all the shapes 
var orderOfDrawing : Array = [] # store which one was drawn when 
# it will be used for undo and redo 

var deleted_strokes : Array = [] 
var deleted_shapes : Array = []
var orderOfDeleting : Array = [] 
# this is order of deleting , so it will be used in redo 


func update_canvas() -> void : 
	var stroke_manager = get_tree().root.get_node("/root/main/CanvasContainer/strokeManager")
	stroke_manager.queue_redraw()
	
	var shape_manager = get_tree().root.get_node("/root/main/CanvasContainer/shapeManager")
	shape_manager.queue_redraw()
