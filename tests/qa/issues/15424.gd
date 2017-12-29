extends MainLoop

var testobject1

# main test body
func _iteration(delta):
	test_undoredo_crash()
	
	return true # exit MainLoop

func test_undoredo_crash():
	var undoredo = UndoRedo.new()
	
	undoredo.create_action('test')
	undoredo.add_do_property(testobject1, 'prop', []) # crash
	undoredo.add_do_method(testobject1, 'prop', []) # good
	undoredo.add_do_reference(testobject1) # crash
	undoredo.add_undo_property(testobject1, 'prop', []) # crash
	undoredo.add_undo_method(testobject1, 'prop', []) # good
	undoredo.add_undo_reference(testobject1) # crash
	
	undoredo.free()
	
	assert(true)
