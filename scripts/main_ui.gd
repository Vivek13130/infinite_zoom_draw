extends Control
@onready var main_ui: Control = $"."

# performance info labels : 
@onready var fps_label: Label = $MarginContainer/bottomStrip/performanceInfo/FPS/MarginContainer/HBoxContainer/fpsLabel
@onready var render_calls_label: Label = $MarginContainer/bottomStrip/performanceInfo/renderCalls/MarginContainer/HBoxContainer/renderCallsLabel
@onready var total_storage_label: Label = $MarginContainer/bottomStrip/performanceInfo/totalPointsInStorage/MarginContainer/HBoxContainer/totalStorageLabel


@onready var color_picker_container: PanelContainer = $ColorPickerContainer
@onready var color_picker_button: TextureButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ColorPicker/ColorPickerButton
@onready var picked_color_rect: ColorRect = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ColorPicker/ColorPickerButton/ColorRect


@onready var zoom_level: Label = $MarginContainer/bottomStrip/leftSideControls/zoomControls/MarginContainer/HBoxContainer/zoomLevel


@onready var brush_size_slider: HSlider = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/BrushTools/brushSizeSlider
@onready var brush_transparency_slider: HSlider = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/BrushTools/brushTransparencySlider
@onready var brushes_drop_down: OptionButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/BrushTools/brushesDropDown
@onready var brush_effect_drop_down: OptionButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/BrushTools/brushEffectDropDown


@onready var shapes_drop_down: OptionButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ShapeTools/shapesDropDown
@onready var shape_effect_drop_down: OptionButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ShapeTools/shapeEffectDropDown
@onready var sppawn_radius_slider: HSlider = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ShapeTools/sppawnRadiusSlider
@onready var spawn_density_slider: HSlider = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ShapeTools/spawnDensitySlider

func _ready() -> void:
	# updating the current state in manager of brush and shapes 
	update_ui_selection_in_manager()
	

func update_ui_selection_in_manager() :
	Manager.brush_type = Manager.brushes_available[brushes_drop_down.get_selected_id()]
	Manager.brush_size = brush_size_slider.value
	Manager.brush_transparency = brush_transparency_slider.value 
	Manager.brush_effect_type = Manager.brush_effect_available[brush_effect_drop_down.get_selected_id()]
	
	Manager.shape_type = Manager.shapes_available[shapes_drop_down.get_selected_id()]
	Manager.shape_effect_type = Manager.shape_effects_available[shape_effect_drop_down.get_selected_id()]
	Manager.shape_spawn_density = spawn_density_slider.value
	Manager.shape_spawn_radius = sppawn_radius_slider.value

func _process(_delta: float) -> void:
	render_calls_label.text = "Re-render calls : " + str(Manager.queue_redraw_calls)
	zoom_level.text = str(int(Manager.zoom_level.x * 100)) + "%"
	fps_label.text = "FPS : " + str(Engine.get_frames_per_second())
	total_storage_label.text = "Total Points Stored : " + str(Manager.total_points_stored)
	
	if(Manager.picked_color != Manager.new_picked_color):
		color_picker_container.visible = false 
		# hiding it because new color is picked 
		Manager.picked_color = Manager.new_picked_color
		picked_color_rect.color = Manager.picked_color
		
	
func _on_color_picker_button_pressed() -> void:
	print("color picker button pressed")
	color_picker_container.position = color_picker_button.global_position + Vector2(120, -40)
	color_picker_container.visible = true


func _on_brushes_drop_down_item_selected(index: int) -> void:
	Manager.brush_type = Manager.brushes_available[index]
	print("new brush selected : ", Manager.brush_type)
	# no shapes , no extra effects  
	shapes_drop_down.select(Manager.shapes_available.size() - 1)
	shape_effect_drop_down.select(Manager.shape_effects_available.size()-1)
	if Manager.brush_type == "None" : 
		brush_effect_drop_down.select(Manager.brush_effect_available.size()-1)
	update_ui_selection_in_manager()
	
func _on_brush_effect_drop_down_item_selected(index: int) -> void:
	Manager.brush_effect_type = Manager.brush_effect_available[index]
	print("new brush effect selected : ", Manager.brush_effect_type)
	# no shapes , no extra effects  
	shapes_drop_down.select(Manager.shapes_available.size() - 1)
	shape_effect_drop_down.select(Manager.shape_effects_available.size()-1)
	
	if(Manager.brush_type == "None"):
		Manager.brush_type = Manager.brushes_available[0]
		brushes_drop_down.select(0)
	update_ui_selection_in_manager()
	

func _on_shapes_drop_down_item_selected(index: int) -> void:
	Manager.shape_type = Manager.shapes_available[index]
	print("new shape selected : ", Manager.shape_type)
	brushes_drop_down.select(Manager.brushes_available.size()-1)
	brush_effect_drop_down.select(Manager.brush_effect_available.size()-1)
	if(index == Manager.shapes_available.size()-1):
		shape_effect_drop_down.select(Manager.shape_effects_available.size()-1)
	update_ui_selection_in_manager()
	


func _on_shape_effect_drop_down_item_selected(index: int) -> void:
	Manager.shape_effect_type = Manager.shape_effects_available[index]
	print("new extra effect selected : ", Manager.shape_effect_type)
	brushes_drop_down.select(Manager.brushes_available.size()-1)
	brush_effect_drop_down.select(Manager.brush_effect_available.size()-1)
	
	if(shapes_drop_down.get_selected_id() == Manager.shapes_available.size()-1):
		Manager.shape_type = Manager.shapes_available[0]
		shapes_drop_down.select(0)
	update_ui_selection_in_manager()
	

func _on_brush_size_value_changed(value: float) -> void:
	Manager.brush_size = value


func _on_brush_transparency_value_changed(value: float) -> void:
	Manager.brush_transparency = value


func _on_spawn_radius_value_changed(value: float) -> void:
	Manager.shape_spawn_radius = value


func _on_spawn_density_value_changed(value: float) -> void:
	Manager.shape_spawn_density = value


func _on_undo_button_pressed() -> void:
	print("undo clicked")
	Manager.undo()


func _on_redo_button_pressed() -> void:
	print("redo clicked")
	Manager.redo()


func _on_drawing_tools_container_mouse_entered() -> void:
	print("Mouse Entered")
	main_ui.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_drawing_tools_container_mouse_exited() -> void:
	print("Mouse Exited")
	main_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
