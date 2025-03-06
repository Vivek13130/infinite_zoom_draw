extends Control
@onready var label: Label = $MarginContainer/bottomStrip/leftSideControls/renderCalls/MarginContainer/HBoxContainer/Label

func _process(delta: float) -> void:
	label.text = "Re-render calls : " + str(Manager.queue_redraw_calls)
