extends Camera2D
#Responsibility : 
#control zoom in and out with limits
#panning via w , a , s, d
#click and drag

@export var updateCanvasDynamically = false 

@onready var canvas_container: Node2D = $".."
@onready var stroke_manager: Node2D = $"../strokeManager"

const zoom_in_limit = 2 * 10e7

# zooming : 
var zoomTarget : Vector2
@export var zoomSpeed : float = 5

# panning : 
@export var panSpeed : int = 2

# click and drag : 
var dragStartMousePos : Vector2
var dragStartCameraPos : Vector2
var isDragging : bool = false 

func _ready() -> void:
	zoomTarget = zoom

func _process(delta: float) -> void:
	simple_zoom(delta)
	click_and_drag(delta)
	simple_panning(delta)


func simple_zoom(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoomTarget *= 1.1
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoomTarget *= 0.9
	
	zoomTarget.x = clamp(zoomTarget.x, 0 , zoom_in_limit)
	zoomTarget.y = clamp(zoomTarget.y, 0 , zoom_in_limit)
	
	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)
	if updateCanvasDynamically:
		stroke_manager.queue_redraw()
	
	Manager.zoom_level = zoom

func click_and_drag(_delta):
	if(!isDragging and Input.is_action_just_pressed("camera_dragging")):
		dragStartCameraPos = position
		dragStartMousePos = get_viewport().get_mouse_position()
		isDragging = true
	
	if(isDragging):
		var moveVector : Vector2 = get_viewport().get_mouse_position() - dragStartMousePos
		position = dragStartCameraPos - moveVector * (1 / zoom.x)
	
	if (isDragging and Input.is_action_just_released("camera_dragging")):
		isDragging = false
		
	if updateCanvasDynamically:
		stroke_manager.queue_redraw()


func simple_panning(delta):
	var movement = Vector2.ZERO
	
	if Input.is_action_pressed("camera_move_down"):
		movement.y -= panSpeed / zoom.x
	if Input.is_action_pressed("camera_move_left"):
		movement.x += panSpeed / zoom.x
	if Input.is_action_pressed("camera_move_right"):
		movement.x -= panSpeed / zoom.x
	if Input.is_action_pressed("camera_move_up"):
		movement.y += panSpeed / zoom.x
	
	position += movement.normalized() * (1 / zoom.x) * delta * 200
	
	if updateCanvasDynamically:
		stroke_manager.queue_redraw()
