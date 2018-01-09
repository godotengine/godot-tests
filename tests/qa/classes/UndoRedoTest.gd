extends MainLoop

var testobject1
var undoredo

func _initialize():
	testobject1 = TestClass.new()
	testobject1.set_prop(1)
	
	undoredo = UndoRedo.new()

# main test body
func _iteration(delta):
	test_create_empty()
	test_create_method()
	test_create_property()
	
	test_undo_one()
	test_undo_two()
	
	test_redo()
	
	test_undo_more()
	
	test_create_create_bug()
	
	return true # exit MainLoop

func _finalize():
	undoredo.free()

func test_create_empty():
	undoredo.create_action('noop action')
	undoredo.commit_action()
	
	assert(testobject1.prop == 1)

func test_create_method():
	undoredo.create_action('first action - method')
	undoredo.add_do_method(testobject1, 'set_prop', 2)
	undoredo.add_undo_method(testobject1, 'set_prop', testobject1.get_prop())
	undoredo.commit_action()
	
	assert(testobject1.prop == 2)

func test_create_property():
	undoredo.create_action('second action - property')
	undoredo.add_do_property(testobject1, 'prop', 3)
	undoredo.add_undo_property(testobject1, 'prop', testobject1.prop)
	undoredo.commit_action()
	
	assert(testobject1.prop == 3)

func test_undo_one():
	undoredo.undo()
	
	assert(testobject1.prop == 2)

func test_undo_two():
	undoredo.undo()
	
	assert(testobject1.prop == 1)

func test_redo():
	undoredo.redo()
	
	assert(testobject1.prop == 2)

func test_undo_more():
	undoredo.undo() # this should be our noop action now
	assert(testobject1.prop == 1)
	
	undoredo.undo() # this should be a Godot noop
	assert(testobject1.prop == 1)
	
	undoredo.redo() # our noop action again
	assert(testobject1.prop == 1)
	
	undoredo.redo() # first action
	assert(testobject1.prop == 2)
	
	undoredo.redo() # second action
	assert(testobject1.prop == 3)
	
	undoredo.redo() # this should be a Godot noop
	assert(testobject1.prop == 3)

func test_create_create_bug():
	undoredo.create_action('botched action')
	# how to cancel/rollback unwanted action?
	
	undoredo.create_action('third action')
	undoredo.add_do_property(testobject1, 'prop', 4)
	undoredo.add_undo_property(testobject1, 'prop', testobject1.prop)
	undoredo.commit_action()
	
	assert(testobject1.prop == 4)
	
	undoredo.redo() # a noop
	undoredo.undo() # second action
	
	assert(testobject1.prop == 3)

class TestClass:
	var prop
	
	func get_prop():
		return prop
	
	func set_prop(prop):
		self.prop = prop
