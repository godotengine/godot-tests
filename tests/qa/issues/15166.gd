extends SceneTree

func _initialize(): # MainLoop
	var viewport = get_root()
	
	var color_rect = ColorRect.new()
	color_rect.rect_size = viewport.get_visible_rect().size
	
	var shader = Shader.new()
	shader.set_code("""
		shader_type canvas_item;
		
		uniform vec2 thing = vec2(1.0); // bug
	""")
	
	var material = ShaderMaterial.new()
	material.set_shader(shader)
	
	color_rect.material = material
	
	viewport.add_child(color_rect)

# main test body
func _iteration(delta): # MainLoop
	test_shader_vec2_constructor()
	
	quit()

func test_shader_vec2_constructor():
	# how would we test for a shader compiler error?
	assert(true)
