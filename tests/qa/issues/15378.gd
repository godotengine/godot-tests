extends MainLoop

var basearray1 = [1, 2, 3]
var basearray2 = Array([1, 2, 3])
var basearray3 = [1, 3, 3]
var basearray4 = [4, 5, 6]

var pba1 = PoolByteArray(basearray1)
var pba2 = PoolByteArray(basearray2)
var pba3 = PoolByteArray(basearray3)
var pba4 = PoolByteArray(basearray4)

var image1
var image2
var image3

func _initialize():
	image1 = Image.new()
	image1.create(1, 1, false, Image.FORMAT_RGBA8)
	image1.lock()
	image1.set_pixel(0, 0, Color(1, 0, 0, 1))
	image1.unlock()
	
	image2 = Image.new()
	image2.create(1, 1, false, Image.FORMAT_RGBA8)
	image2.lock()
	image2.set_pixel(0, 0, Color(1, 0, 0, 1))
	image2.unlock()
	
	image3 = Image.new()
	image3.create(1, 1, false, Image.FORMAT_RGBA8)
	image3.lock()
	image3.set_pixel(0, 0, Color(0, 1, 0, 1))
	image3.unlock()

# main test body
func _iteration(delta):
	test_array_comparison()
	test_pba_comparison()
	test_image_pba_comparison()
	
	return true # exit MainLoop

func test_array_comparison():
	assert(basearray1 == basearray2)
	assert(!(basearray1 != basearray2))
	
	assert(basearray1 != basearray3) # mrcdk issue (root)
	assert(!(basearray1 == basearray3))
	
	assert(basearray1 != basearray4)
	assert(!(basearray1 == basearray4))

func test_pba_comparison():
	assert(pba1 == pba2)
	assert(!(pba1 != pba2))
	
	assert(pba1 != pba3) # mrcdk issue (root)
	assert(!(pba1 == pba3))
	
	assert(pba1 != pba4)
	assert(!(pba1 == pba4))

func test_image_pba_comparison():
	assert(image1.get_data() == image2.get_data())
	assert(!(image1.get_data() != image2.get_data()))
	
	assert(image1.get_data() != image3.get_data()) # original issue
	assert(!(image1.get_data() == image3.get_data()))
