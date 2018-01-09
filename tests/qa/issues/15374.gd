extends MainLoop

# main test body
func _iteration(delta):
	test_set_pixel_docs()
	test_resize_crash()
	
	return true # exit MainLoop

func test_set_pixel_docs():
	var image = Image.new()
	image.create(1, 1, false, Image.FORMAT_RGBA8) # docs
	image.lock()
	image.set_pixel(0, 0, Color(1, 0, 0, 1))
	image.unlock()
	assert(true)

func test_resize_crash():
	var image = Image.new()
	image.resize(1, 1) # crash
	assert(true)
