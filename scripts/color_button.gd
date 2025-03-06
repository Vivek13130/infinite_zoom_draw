extends Button


func _on_pressed() -> void:
	var color_rect : ColorRect = get_child(0)
	Manager.new_picked_color = color_rect.color
	get_parent().get_parent().get_parent().visible = false
