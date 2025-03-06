extends Control

@onready var label: Label = $MarginContainer/bottomStrip/leftSideControls/renderCalls/MarginContainer/HBoxContainer/Label
@onready var color_picker_container: PanelContainer = $ColorPickerContainer
@onready var color_picker_button: TextureButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ColorPicker/ColorPickerButton
@onready var picked_color_rect: ColorRect = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ColorPicker/ColorPickerButton/ColorRect


@onready var brushes_drop_down: OptionButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/BrushTools/brushesDropDown
@onready var brush_effect_drop_down: OptionButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/BrushTools/brushEffectDropDown

@onready var shapes_drop_down: OptionButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ShapeTools/shapesDropDown
@onready var shape_effect_drop_down: OptionButton = $MarginContainer/drawingToolsContainer/MarginContainer/MainContainer/ShapeTools/shapeEffectDropDown


func _process(_delta: float) -> void:
	label.text = "Re-render calls : " + str(Manager.queue_redraw_calls)
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
	shape_effect_drop_down.select(Manager.extra_effects_available.size()-1)

func _on_shapes_drop_down_item_selected(index: int) -> void:
	Manager.shape_type = Manager.shapes_available[index]
	print("new shape selected : ", Manager.shape_type)
	brushes_drop_down.select(Manager.brushes_available.size()-1)
	if(index == Manager.shapes_available.size()-1):
		shape_effect_drop_down.select(Manager.extra_effects_available.size()-1)



func _on_shape_effect_drop_down_item_selected(index: int) -> void:
	Manager.extra_effect_type = Manager.extra_effects_available[index]
	print("new extra effect selected : ", Manager.extra_effect_type)
	brushes_drop_down.select(Manager.brushes_available.size()-1)
	
	print(Manager.shape_type)
	print(shapes_drop_down.get_selected_id())
	if(shapes_drop_down.get_selected_id() == Manager.shapes_available.size()-1):
		Manager.shape_type = Manager.shapes_available[0]
		shapes_drop_down.select(0)
