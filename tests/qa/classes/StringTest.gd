extends MainLoop

var test_string = 'Lorem Ipsum'

var unix_root = '/'
var unix_file_sans_extension = '/abc.def/ghi'
var unix_file_with_extension = '/abc.def/ghi.jkl'
var unix_dir = '/abc.def/ghi.jkl/'

var windows_root = 'C:/'
var windows_file_sans_extension = 'C:/abc.def/ghi'
var windows_file_with_extension = 'C:/abc.def/ghi.jkl'
var windows_dir = 'C:/abc.def/ghi.jkl/'

# main test body
func _iteration(delta):
	test_begins_with_test_string()
	test_ends_with_test_string()
	
	test_find_test_string()
	
	test_get_base_dir_test_string()
	test_get_base_dir_unix_root()
	test_get_base_dir_unix_file_sans_extension()
	test_get_base_dir_unix_file_with_extension()
	test_get_base_dir_unix_dir()
	test_get_base_dir_windows_root()
	test_get_base_dir_windows_file_sans_extension()
	test_get_base_dir_windows_file_with_extension()
	test_get_base_dir_windows_dir()
	
	test_get_basename_test_string()
	test_get_basename_unix_root()
	test_get_basename_unix_file_sans_extension()
	test_get_basename_unix_file_with_extension()
	test_get_basename_unix_dir()
	test_get_basename_windows_root()
	test_get_basename_windows_file_sans_extension()
	test_get_basename_windows_file_with_extension()
	test_get_basename_windows_dir()
	
	test_get_extension_test_string()
	test_get_extension_unix_root()
	test_get_extension_unix_file_sans_extension()
	test_get_extension_unix_file_with_extension()
	test_get_extension_unix_dir()
	test_get_extension_windows_root()
	test_get_extension_windows_file_sans_extension()
	test_get_extension_windows_file_with_extension()
	test_get_extension_windows_dir()
	
	return true # exit MainLoop

func test_begins_with_test_string():
	assert(test_string.begins_with('Lorem') == true)
	assert(test_string.begins_with('Ipsum') == false)

func test_ends_with_test_string():
	assert(test_string.ends_with('Lorem') == false)
	assert(test_string.ends_with('Ipsum') == true)

func test_find_test_string():
	# default index value test
	assert(test_string.find(' ', 0) == test_string.find(' '))
	
	# index value out of bounds
	assert(test_string.find(' ', -1) == -1)
	assert(test_string.find(' ', test_string.length()) == -1)
	
	# bad sub string test
	#assert(test_string.find(null) == -1) # parser doesn't allow
	assert(test_string.find('') == -1)
	
	# bounds checking
	assert(test_string.find(' ', 5) == 5)
	assert(test_string.find(' ', 6) == -1)
	
	# multi character sub string test
	assert(test_string.find('Ip') == 6)

# test_get_base_dir

func test_get_base_dir_test_string():
	# not really a fair test, but highlights API mismatch
	#assert(test_string.get_base_dir() == '')
	pass
	
func test_get_base_dir_unix_root():
	assert(unix_root.get_base_dir() == unix_root)
	
func test_get_base_dir_unix_file_sans_extension():
	assert(unix_file_sans_extension.get_base_dir() == '/abc.def')
	
func test_get_base_dir_unix_file_with_extension():
	assert(unix_file_with_extension.get_base_dir() == '/abc.def')
	
func test_get_base_dir_unix_dir():
	assert(unix_dir.get_base_dir() == unix_file_with_extension)
	
func test_get_base_dir_windows_root():
	assert(windows_root.get_base_dir() == 'C:') # hmmm
	
func test_get_base_dir_windows_file_sans_extension():
	assert(windows_file_sans_extension.get_base_dir() == 'C:/abc.def')
	
func test_get_base_dir_windows_file_with_extension():
	assert(windows_file_with_extension.get_base_dir() == 'C:/abc.def')
	
func test_get_base_dir_windows_dir():
	assert(windows_dir.get_base_dir() == windows_file_with_extension)

# test_get_basename

func test_get_basename_test_string():
	# not really a fair test, but highlights API mismatch
	#assert(test_string.get_basename() == '') # bug, not a path
	pass
	
func test_get_basename_unix_root():
	assert(unix_root.get_basename() == unix_root)
	
func test_get_basename_unix_file_sans_extension():
	print(unix_file_sans_extension.get_basename(), ' == ', unix_file_sans_extension)
	assert(unix_file_sans_extension.get_basename() == unix_file_sans_extension) # bug, file w/o extension
	
func test_get_basename_unix_file_with_extension():
	assert(unix_file_with_extension.get_basename() == unix_file_sans_extension)
	
func test_get_basename_unix_dir():
	print(unix_dir.get_basename(), ' == ', unix_dir)
	assert(unix_dir.get_basename() == unix_dir) # bug, directory
	
func test_get_basename_windows_root():
	assert(windows_root.get_basename() == windows_root)
	
func test_get_basename_windows_file_sans_extension():
	print(windows_file_sans_extension.get_basename(), ' == ', windows_file_sans_extension)
	assert(windows_file_sans_extension.get_basename() == windows_file_sans_extension) # bug, file w/o extension, dupe
	
func test_get_basename_windows_file_with_extension():
	assert(windows_file_with_extension.get_basename() == windows_file_sans_extension)
	
func test_get_basename_windows_dir():
	print(windows_dir.get_basename(), ' == ', windows_dir)
	assert(windows_dir.get_basename() == windows_dir) # bug, directory, dupe

# test_get_extension

func test_get_extension_test_string():
	# not really a fair test, but highlights API mismatch
	#assert(test_string.get_extension() == '') # bug, not a path
	pass
	
func test_get_extension_unix_root():
	print(unix_root.get_extension(), ' == ', '<empty>')
	assert(unix_root.get_extension() == '') # bug, not a file
	
func test_get_extension_unix_file_sans_extension():
	print(unix_file_sans_extension.get_extension(), ' == ', '<empty>')
	assert(unix_file_sans_extension.get_extension() == '') # bug, file w/o extension
	
func test_get_extension_unix_file_with_extension():
	assert(unix_file_with_extension.get_extension() == 'jkl')
	
func test_get_extension_unix_dir():
	print(unix_dir.get_extension(), ' == ', '<empty>')
	assert(unix_dir.get_extension() == '') # bug, not a file, dupe
	
func test_get_extension_windows_root():
	print(windows_root.get_extension(), ' == ', '<empty>')
	assert(windows_root.get_extension() == '') # bug, not a file, dupe
	
func test_get_extension_windows_file_sans_extension():
	print(windows_file_sans_extension.get_extension(), ' == ', '<empty>')
	assert(windows_file_sans_extension.get_extension() == '') # bug, file w/o extension, dupe
	
func test_get_extension_windows_file_with_extension():
	assert(windows_file_with_extension.get_extension() == 'jkl')
	
func test_get_extension_windows_dir():
	print(windows_dir.get_extension(), ' == ', '<empty>')
	assert(windows_dir.get_extension() == '') # bug, not a file, dupe
