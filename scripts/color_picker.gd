extends PanelContainer
@onready var color_picker: GridContainer = $MarginContainer/ColorPicker

var bright_colors = Manager.pickable_colors


var color_button : PackedScene = preload("res://scenes/color_button.tscn")

func _ready() -> void:
	for color in bright_colors:
		var button = color_button.instantiate()
		button.get_child(0 , false).color = color
		color_picker.add_child(button)
	
