extends MainLoop

# main test body
func _iteration(delta):
	test_14799()
	
	return true # exit MainLoop

func test_14799():
	assert('1 2 3 4 5'.split(' ').size() == 5)
