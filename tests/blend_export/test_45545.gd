extends ColorRect

const GOLDEN_GLTF_SCENE: PackedScene = preload("res://gltf/45545-relax-name-sanitization.gltf")

## These constants are the prefix part of the node names used in the golden glTF file.
# Prefix for "basic" nodes, no import hints, no animation, etc...
const GLTF_PREFIX_BASIC: String = "Basic_"

# Prefix for nodes that have an import hint.
const GLTF_PREFIX_HINTED: String = "Hinted_"

# Prefix for nodes that have an associated animation.
const GLTF_PREFIX_ANIMATED: String = "Animated_"

## These constants are the infix part of the node names used in the golden glTF file.
const GLTF_ALPHANUMERIC: String = "Alphanumeric123"
# The last three symbols are:
# https://en.wiktionary.org/wiki/%E3%82%B4#Japanese
# https://en.wiktionary.org/wiki/%E3%83%89#Japanese
# https://en.wiktionary.org/wiki/%E3%83%84#Japanese
const GLTF_KATAKANA: String = "Katakana_ゴドツ"
# The last two symbols are:
# https://emojipedia.org/grinning-face
# https://emojipedia.org/robot/
const GLTF_EMOJI: String = "Emoji_😀🤖"
const GLTF_ALLOWED_SYMBOLS: String = "AllowedSymbols_!#$%^&*()-=[]{}';<>,~"
const GLTF_DISALLOWED_NONCLASHING: String = "Disallowed_Non-clashing_.:@\"/"
const GLTF_DISALLOWED_CLASHING_1: String = "Disallowed_Clashing_."
const GLTF_DISALLOWED_CLASHING_2: String = "Disallowed_Clashing_@"
const GLTF_DISALLOWED_CLASHING_DEEP_TREE_1: String = "Disallowed_Clashing_Deep_Tree_@"
const GLTF_DISALLOWED_CLASHING_DEEP_TREE_2: String = "Disallowed_Clashing_Deep_Tree_@@"
const GLTF_DISALLOWED_CLASHING_DEEP_TREE_3: String = "Disallowed_Clashing_Deep_Tree_@@@"

var output: BoxContainer
var test_scene: Node


func _ready():
	output = $ScrollContainer/OutputWindow
	test_scene = GOLDEN_GLTF_SCENE.instance()

	var passed_tests: Array = []
	var failed_tests: Array = []

	for method_name in _find_tests():
		_add_test_header(method_name)
		var result: bool = self.call(method_name)
		_add_line(" ")
		if result:
			passed_tests.push_back(method_name)
		else:
			failed_tests.push_back(method_name)
	
	if failed_tests:
		print("%d failed tests:" % len(failed_tests))
		for test in failed_tests:
			print("\t%s" % test)
	else:
		print("Passed all %d tests" % len(passed_tests))


func _find_tests() -> Array:
	var ret: Array = []
	for method in get_method_list():
		var method_name: String = method.get("name")
		if method_name.begins_with("_test_"):
			ret.push_back(method_name)
	ret.sort()
	return ret


func _add_test_header(method_name: String) -> void:
	_add_line(method_name, Color.royalblue)


func _add_result(succeeded: bool, message: String) -> void:
	var prefix: String = "  [OK] " if succeeded else "  [FAIL] "
	_add_line(prefix + message, Color.forestgreen if succeeded else Color.orangered)


func _add_line(text: String, color: Color = Color.white) -> void:
	var line: Label = Label.new()
	line.text = text
	line.add_theme_font_size_override("font_size", 22)
	line.add_theme_color_override("font_color", color)
	output.add_child(line)


func _check_basic(original: String, expected: String) -> bool:
	var node: Node = test_scene.get_node_or_null(expected)
	if not node:
		_add_result(
			false,
			"Missing expected Godot node '%s' for glTF node '%s'" % [expected, original])
		return false
	_add_result(true, "Found expected node '%s'" % expected)
	return true


func _test_basic_alphanumeric_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_ALPHANUMERIC
	var expected: String = original
	return _check_basic(original, expected)


func _test_basic_allowed_symbols_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_ALLOWED_SYMBOLS
	var expected: String = original
	return _check_basic(original, expected)


func _test_basic_katakana_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_KATAKANA
	var expected: String = original
	return _check_basic(original, expected)


func _test_basic_emoji_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_EMOJI
	var expected: String = original
	return _check_basic(original, expected)


func _test_basic_disallowed_characters_are_stripped() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_NONCLASHING
	var expected: String = GLTF_PREFIX_BASIC + "Disallowed_Non-clashing_"
	return _check_basic(original, expected)


func _test_basic_disallowed_clashing_nodes_are_uniquified() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_1
	var expected: String = GLTF_PREFIX_BASIC + "Disallowed_Clashing_"
	if not _check_basic(original, expected):
		return false

	original = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_2
	expected = GLTF_PREFIX_BASIC + "Disallowed_Clashing_2"
	return _check_basic(original, expected)


func _test_basic_disallowed_nested_nodes_are_uniquified() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_DEEP_TREE_1
	var expected_root: String = GLTF_PREFIX_BASIC + "Disallowed_Clashing_Deep_Tree_"
	if not _check_basic(original, expected_root):
		return false

	original = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_DEEP_TREE_2
	var expected_mid = expected_root + "/" + GLTF_PREFIX_BASIC + "Disallowed_Clashing_Deep_Tree_2"
	if not _check_basic(original, expected_mid):
		return false

	original = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_DEEP_TREE_3
	var expected_leaf = expected_mid + "/" + GLTF_PREFIX_BASIC + "Disallowed_Clashing_Deep_Tree_3"
	return _check_basic(original, expected_leaf)


# Verifies that a node exists with the expected name and that it has a StaticBody3D child.
func _check_hinted_col(original: String, expected: String) -> bool:
	var node: Node = test_scene.get_node_or_null(expected)
	if not node:
		_add_result(
			false,
			"Missing expected Godot node '%s' for glTF node '%s'" % [expected, original])
		return false
		
	var collision_body: StaticBody3D = node.get_node_or_null("static_collision")
	if not collision_body:
		_add_result(
			false,
			"Missing 'static_collision' child for Godot node '%s' (glTF '%s')" % [
				expected, original])
		return false
		
	# This test assumes that if the static_collision node was created the -col hint was properly
	# handled (as that behavior should be tested elsewhere).
	_add_result(true, "Expected node '%s' contains a static_collision StaticBody3D" % expected)
	return true


func _test_hinted_alphanumeric_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_ALPHANUMERIC
	var expected: String = original
	return _check_basic(original, expected)


func _test_hinted_allowed_symbols_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_ALLOWED_SYMBOLS
	var expected: String = original
	return _check_hinted_col(original, expected)


func _test_hinted_katakana_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_KATAKANA
	var expected: String = original
	return _check_hinted_col(original, expected)


func _test_hinted_emoji_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_EMOJI
	var expected: String = original
	return _check_hinted_col(original, expected)


func _test_hinted_disallowed_characters_are_stripped() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_NONCLASHING
	var expected: String = GLTF_PREFIX_BASIC + "Disallowed_Non-clashing_"
	return _check_hinted_col(original, expected)


func _test_hinted_disallowed_clashing_nodes_are_uniquified() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_1
	var expected: String = GLTF_PREFIX_BASIC + "Disallowed_Clashing_"
	if not _check_hinted_col(original, expected):
		return false

	original = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_2
	expected = GLTF_PREFIX_BASIC + "Disallowed_Clashing_2"
	return _check_hinted_col(original, expected)


func _test_hinted_disallowed_nested_nodes_are_uniquified() -> bool:
	var original: String = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_DEEP_TREE_1
	var expected_root: String = GLTF_PREFIX_BASIC + "Disallowed_Clashing_Deep_Tree_"
	if not _check_hinted_col(original, expected_root):
		return false

	original = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_DEEP_TREE_2
	var expected_mid = expected_root + "/" + GLTF_PREFIX_BASIC + "Disallowed_Clashing_Deep_Tree_2"
	if not _check_hinted_col(original, expected_mid):
		return false

	original = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_DEEP_TREE_3
	var expected_leaf = expected_mid + "/" + GLTF_PREFIX_BASIC + "Disallowed_Clashing_Deep_Tree_3"
	return _check_hinted_col(original, expected_leaf)

