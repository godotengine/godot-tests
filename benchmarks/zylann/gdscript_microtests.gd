# This script prints how much time GDScript takes to performs specific instructions.

# Times values are in arbitrary units but share the same scale,
# so for example if test A prints 100 and test B prints 200,
# we can say that test A is 2x faster than test B.

# All tests run a very long loop containing the code to profile,
# in order to obtain a reasonable time information.
# The cost of the loop itself is then subtracted to all tests.
# Iteration count is the same for all tests.
# There shouldn't be race conditions between loops.

# Results will be approximate and vary between executions and CPU speed,
# but the error margin should be low enough to make conclusions on most tests.
# If not, please set the ITERATIONS constant to higher values to reduce the margin.


# TODO Output results in a JSON file so we can reload and compare them afterwards
# TODO Add tests for complete algorithms such as primes, fibonacci etc
# TODO Add tests on strings

tool
extends SceneTree

# How many times test loops are ran. Higher is slower, but gives better average.
const ITERATIONS = 500000

# Per case:
# True: print time for 1 loop
# False: print time for all loops
const PRINT_PER_TEST_TIME = false

var _time_before = 0
var _for_time = 0
var _test_name = ""
var _test_results = []

# ---------
# Members used by tests
var _test_a = 1
# ---------


func _init():
	_ready()
	quit()


func _ready():
	print("-------------------")
	
	_time_before = OS.get_ticks_msec()
	
	start()
	
	for i in range(0,ITERATIONS):
		pass
	
	_for_time = stop()
	print("For time: " + str(_for_time))
	
	print("")
	if PRINT_PER_TEST_TIME:
		print("The following times are in microseconds taken for 1 test.")
	else:
	 	print("The following times are in seconds for the whole test.")
	print("")

	#-------------------------------------------------------
	test_empty_func()
	test_increment()
	test_increment_x5()
	test_increment_with_member_var()
	test_increment_with_local_outside_loop()
	test_increment_with_local_inside_loop()
	test_increment_vector2()
	test_increment_vector3()
	test_increment_vector3_constant()
	test_increment_vector3_individual_xyz()
	test_unused_local()
	test_divide()
	test_increment_with_dictionary_member()
	test_increment_with_array_member()
	test_while_time()
	test_if_true()
	test_if_true_else()
	test_variant_array_resize()
	test_variant_array_assign()
	test_int_array_resize()
	test_int_array_assign()

	print("-------------------")
	print("Done.")


func start(name=""):
	_test_name = name
	_time_before = OS.get_ticks_msec()


func stop():
	var time = OS.get_ticks_msec() - _time_before
	if _test_name.length() != 0:
		var test_time = time - _for_time
		
		if PRINT_PER_TEST_TIME:
			# Time taken for 1 test
			var k = 1000000.0 / ITERATIONS
			test_time = k * test_time
		
		print(_test_name + ": " + str(test_time))# + " (with for: " + str(time) + ")")
		_test_results.append({
			name = _test_name,
			time = test_time
		})
	return time


#-------------------------------------------------------------------------------
func test_empty_func():
	start("Empty func (void function call cost)")
	
	for i in range(0,ITERATIONS):
		empty_func()
	
	stop()

func empty_func():
	pass

#-------------------------------------------------------------------------------
func test_increment():
	var a = 0
	
	start("Increment")
	
	for i in range(0,ITERATIONS):
		a += 1
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_x5():
	var a = 0
	
	start("Increment x5")
	
	for i in range(0,ITERATIONS):
		a += 1
		a += 1
		a += 1
		a += 1
		a += 1
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_with_member_var():
	var a = 0
	
	start("Increment with member var")
	
	for i in range(0,ITERATIONS):
		a += _test_a
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_with_local_outside_loop():
	var a = 0
	var b = 1
	
	start("Increment with local (outside loop)")
	
	for i in range(0,ITERATIONS):
		a += b
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_with_local_inside_loop():
	var a = 0
	
	start("Increment with local (inside loop)")
	
	for i in range(0,ITERATIONS):
		var b = 1
		a += b
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_vector2():
	var a = Vector2(0,0)
	var b = Vector2(1,1)
	
	start("Increment Vector2")
	
	for i in range(0, ITERATIONS):
		a += b
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_vector3():
	var a = Vector3(0,0,0)
	var b = Vector3(1,1,1)
	
	start("Increment Vector3")
	
	for i in range(0, ITERATIONS):
		a += b
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_vector3_constant():
	var a = Vector3(0,0,0)
	
	start("Increment Vector3 with constant")
	
	for i in range(0, ITERATIONS):
		a += Vector3(1,1,1)
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_vector3_individual_xyz():
	var a = Vector3(0,0,0)
	var b = Vector3(1,1,1)
	
	start("Increment Vector3 coordinate by coordinate")
	
	for i in range(0, ITERATIONS):
		a.x += b.x
		a.y += b.y
		a.z += b.z
	
	stop()
	
#-------------------------------------------------------------------------------
func test_unused_local():
	start("Unused local (declaration cost)")
	
	for i in range(0,ITERATIONS):
		var b = 1
	
	stop()

#-------------------------------------------------------------------------------
func test_divide():
	start("Divide")
	
	var a = 9999
	for i in range(0,ITERATIONS):
		a /= 1.01
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_with_dictionary_member():
	start("Increment with dictionary member")
	
	var a = 0
	var dic = {b = 1}
	for i in range(0,ITERATIONS):
		a += dic.b
	
	stop()

#-------------------------------------------------------------------------------
func test_increment_with_array_member():
	start("Increment with array member")
	
	var a = 0
	var arr = [1]
	for i in range(0,ITERATIONS):
		a += arr[0]
	
	stop()

#-------------------------------------------------------------------------------
func test_while_time():
	start("While time")
	
	var i = 0
	while i < ITERATIONS:
		i += 1
		
	print("While time (for equivalent with manual increment): " + str(OS.get_ticks_msec() - _time_before))

#-------------------------------------------------------------------------------
func test_if_true():
	start("if(true) time")
	for i in range(0,ITERATIONS):
		if true:
			pass
	
	stop()

#-------------------------------------------------------------------------------
func test_if_true_else():
	start("if(true)else time")
	for i in range(0,ITERATIONS):
		if true:
			pass
		else:
			pass
	
	stop()

#-------------------------------------------------------------------------------
func test_variant_array_resize():
	start("VariantArray resize")
	for i in range(0,ITERATIONS):
		var line = []
		line.resize(1000)
	
	stop()

#-------------------------------------------------------
func test_variant_array_assign():
	var v_array = []
	v_array.resize(100)
	
	start("VariantArray set element")
	for i in range(0, ITERATIONS):
		v_array[42] = 0
	
	stop()

#-------------------------------------------------------
func test_int_array_resize():
	start("PoolIntArray resize")
	for i in range(0,ITERATIONS):
		var line = PoolIntArray()
		line.resize(1000)
	
	stop()
		
#-------------------------------------------------------
func test_int_array_assign():
	var i_array = PoolIntArray()
	i_array.resize(100)

	start("PoolIntArray set element")
	for i in range(0, ITERATIONS):
		i_array[42] = 0
	
	stop()
