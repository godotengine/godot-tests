extends SceneTree

func _init(): # Object
	VisualServer.set_debug_generate_wireframes(true) # this

func _initialize(): # MainLoop
	var viewport = get_root()
	
	var environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.background_sky = ProceduralSky.new()
	
	viewport.world.environment = environment
	
	var camera = Camera.new()
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = CubeMesh.new()
	mesh_instance.transform.origin.z = -5
	
	camera.add_child(mesh_instance)
	
	viewport.add_child(camera)

var before_image
var after_image

# it takes 6 _iterations to have usable viewport texture data, add buffer
const DELAY_CYCLES = 6 * 2

var delay = DELAY_CYCLES

# main test body
func _iteration(delta): # MainLoop
	if delay > 0:
		delay -= 1
		
		return false # return true in MainLoop exits, keep going?
	
	var viewport = get_root()
	
	if !before_image:
		before_image = viewport.get_texture().get_data()
		#before_image.flip_y()
		#before_image.save_png('/tmp/15149.1_before_image.png')
		
		viewport.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		
		delay = DELAY_CYCLES
		
		return false
	
	after_image = viewport.get_texture().get_data()
	#after_image.flip_y()
	#after_image.save_png('/tmp/15149.2_after_image.png')
	
	test_viewport_wireframe()
	
	quit()

func test_viewport_wireframe():
	# issue 15378 bites us
	#assert(before_image.get_data() != after_image.get_data())
	assert(!(before_image.get_data() == after_image.get_data()))
	
	# we could also save a known-good copy and assert the after_image matches
