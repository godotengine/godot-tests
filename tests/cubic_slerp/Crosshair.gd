extends Sprite2D


func _process(_delta):
	var camera = get_node("../Head/FirstPersonCamera")
	var firstPerson = get_node("..")
	if (camera.current and firstPerson.mouse_captured):
		var center = get_viewport_rect().size
		self.position = center / 2
		self.visible = true
	else:
		self.visible = false
