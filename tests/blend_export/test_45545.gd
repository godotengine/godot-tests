extends ColorRect

const GOLDEN_GLTF_SCENE: PackedScene = preload("res://gltf/45545-relax-name-sanitization.gltf")

## These constants are the prefix part of the node names used in the golden glTF file.
# Prefix for "basic" nodes, no import hints, no animation, etc...
const GLTF_PREFIX_BASIC: String = "Basic_"

# Prefix for nodes that have an import hint.
const GLTF_PREFIX_HINTED: String = "Hinted_"

# Prefix for nodes that have an associated animation.
const GLTF_PREFIX_ANIMATED: String = "Animated_"

# The suffix for animations (all animations in the golden glTF file use the Blender default suffix
# "Action" and the looping import hint "-loop".
const GLTF_SUFFIX_ANIMATION: String = "Action-loop"

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
var test_animation_player: AnimationPlayer


func _ready():
	output = $ScrollContainer/OutputWindow
	test_scene = GOLDEN_GLTF_SCENE.instance()
	test_animation_player = test_scene.get_node_or_null("AnimationPlayer")
	if not test_animation_player:
		_add_line("ERROR: imported glTF scene has no AnimationPlayer node!", Color.orangered)
		print("FAIL: imported glTF scene has no AnimationPlayer so no tests will be run.")
		return

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
		print("FAIL: %d failed tests:" % len(failed_tests))
		for test in failed_tests:
			print("\t%s" % test)
		print("")
		print("Animations:")
		for animation_name in test_animation_player.get_animation_list():
			print("\t%s" % animation_name)
	else:
		print("PASS: Passed all %d tests" % len(passed_tests))


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


func _add_line(text: String, font_color: Color = Color.black) -> void:
	var line: Label = Label.new()
	line.text = text
	line.add_theme_font_size_override("font_size", 22)
	line.add_theme_color_override("font_color", font_color)
	output.add_child(line)
	print(text)


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
	# Note: Blender 9.2 serializes in prefix order, so the leaf child will be named first.
	var original: String = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_DEEP_TREE_1
	var expected_root: String = GLTF_PREFIX_BASIC + "Disallowed_Clashing_Deep_Tree_3"
	if not _check_basic(original, expected_root):
		return false

	original = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_DEEP_TREE_2
	var expected_mid = expected_root + "/" + GLTF_PREFIX_BASIC + "Disallowed_Clashing_Deep_Tree_2"
	if not _check_basic(original, expected_mid):
		return false

	original = GLTF_PREFIX_BASIC + GLTF_DISALLOWED_CLASHING_DEEP_TREE_3
	var expected_leaf = expected_mid + "/" + GLTF_PREFIX_BASIC + "Disallowed_Clashing_Deep_Tree_"
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
	var original: String = GLTF_PREFIX_HINTED + GLTF_ALPHANUMERIC
	var expected: String = original
	return _check_hinted_col(original, expected)


func _test_hinted_allowed_symbols_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_HINTED + GLTF_ALLOWED_SYMBOLS
	var expected: String = original
	return _check_hinted_col(original, expected)


func _test_hinted_katakana_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_HINTED + GLTF_KATAKANA
	var expected: String = original
	return _check_hinted_col(original, expected)


func _test_hinted_emoji_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_HINTED + GLTF_EMOJI
	var expected: String = original
	return _check_hinted_col(original, expected)


func _test_hinted_disallowed_characters_are_stripped() -> bool:
	var original: String = GLTF_PREFIX_HINTED + GLTF_DISALLOWED_NONCLASHING
	var expected: String = GLTF_PREFIX_HINTED + "Disallowed_Non-clashing_"
	return _check_hinted_col(original, expected)


func _test_hinted_disallowed_clashing_nodes_are_uniquified() -> bool:
	var original: String = GLTF_PREFIX_HINTED + GLTF_DISALLOWED_CLASHING_1
	var expected: String = GLTF_PREFIX_HINTED + "Disallowed_Clashing_"
	if not _check_hinted_col(original, expected):
		return false

	original = GLTF_PREFIX_HINTED + GLTF_DISALLOWED_CLASHING_2
	expected = GLTF_PREFIX_HINTED + "Disallowed_Clashing_2"
	return _check_hinted_col(original, expected)


func _test_hinted_disallowed_nested_nodes_are_uniquified() -> bool:
	var original: String = GLTF_PREFIX_HINTED + GLTF_DISALLOWED_CLASHING_DEEP_TREE_1
	var expected_root: String = GLTF_PREFIX_HINTED + "Disallowed_Clashing_Deep_Tree_3"
	if not _check_hinted_col(original, expected_root):
		return false

	original = GLTF_PREFIX_HINTED + GLTF_DISALLOWED_CLASHING_DEEP_TREE_2
	var expected_mid = expected_root + "/" + GLTF_PREFIX_HINTED + "Disallowed_Clashing_Deep_Tree_2"
	if not _check_hinted_col(original, expected_mid):
		return false

	original = GLTF_PREFIX_HINTED + GLTF_DISALLOWED_CLASHING_DEEP_TREE_3
	var expected_leaf = expected_mid + "/" + GLTF_PREFIX_HINTED + "Disallowed_Clashing_Deep_Tree_"
	return _check_hinted_col(original, expected_leaf)


# Verifies that a node exists with the expected name and that an associated animation exists.
func _check_animated(original: String, expected: String, expected_animation: String = "") -> bool:
	var node: Node = test_scene.get_node_or_null(expected)
	if not node:
		_add_result(
			false,
			"Missing expected Godot node '%s' for glTF node '%s'" % [expected, original])
		return false

	if expected_animation.is_empty():
		expected_animation = expected + GLTF_SUFFIX_ANIMATION
	var animation: Animation = test_animation_player.get_animation(expected_animation)
	if not animation:
		_add_result(
			false,
			"Missing expected animation '%s' for Godot node '%s' (glTF '%s')" % [
				expected_animation, expected, original])
		return false

	var track_count: int = animation.get_track_count()
	if track_count != 1:
		_add_result(
			false,
			"Track count %d != 1 on animation '%s' for Godot node '%s' (glTF '%s')" % [
				track_count, expected_animation, expected, original])
		return false

	var track_type: int = animation.track_get_type(0)
	if track_type != Animation.TYPE_TRANSFORM:
		_add_result(
			false,
			"Unexpected track type %d on animation '%s' for Godot node '%s' (glTF '%s')" % [
				track_type, expected_animation, expected, original])
		return false

	var track_path: NodePath = animation.track_get_path(0)
	var expected_track_path = NodePath(expected)
	if track_path != expected_track_path:
		_add_result(
			false,
			("Incorrect track_path '%s' (expected '%s') on animation '%s' for Godot node '%s' \
				 (glTF '%s')" % [
					track_path, expected_track_path, expected_animation, expected, original]))
		return false


	# This test assumes that if the static_collision node was created the -col hint was properly
	# handled (as that behavior should be tested elsewhere).
	_add_result(true, "Expected node '%s' has an associated animation" % expected)
	return true


func _test_animated_alphanumeric_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_ANIMATED + GLTF_ALPHANUMERIC
	var expected: String = original
	return _check_animated(original, expected)


func _test_animated_allowed_symbols_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_ANIMATED + GLTF_ALLOWED_SYMBOLS
	var expected_node: String = original
	var expected_animation: String = original.replace(",", "").replace("[", "")
	expected_animation += GLTF_SUFFIX_ANIMATION
	return _check_animated(original, expected_node, expected_animation)


func _test_animated_katakana_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_ANIMATED + GLTF_KATAKANA
	var expected: String = original
	return _check_animated(original, expected)


func _test_animated_emoji_is_unchanged() -> bool:
	var original: String = GLTF_PREFIX_ANIMATED + GLTF_EMOJI
	var expected: String = original
	return _check_animated(original, expected)


func _test_animated_disallowed_characters_are_stripped() -> bool:
	var original: String = GLTF_PREFIX_ANIMATED + GLTF_DISALLOWED_NONCLASHING
	var expected: String = GLTF_PREFIX_ANIMATED + "Disallowed_Non-clashing_"
	return _check_animated(original, expected)


func _test_animated_disallowed_clashing_nodes_are_uniquified() -> bool:
	var original: String = GLTF_PREFIX_ANIMATED + GLTF_DISALLOWED_CLASHING_1
	var expected: String = GLTF_PREFIX_ANIMATED + "Disallowed_Clashing_"
	if not _check_animated(original, expected):
		return false

	original = GLTF_PREFIX_ANIMATED + GLTF_DISALLOWED_CLASHING_2
	expected = GLTF_PREFIX_ANIMATED + "Disallowed_Clashing_2"
	return _check_animated(original, expected)


func _test_animated_disallowed_nested_nodes_are_uniquified() -> bool:
	var original: String = GLTF_PREFIX_ANIMATED + GLTF_DISALLOWED_CLASHING_DEEP_TREE_1
	var expected_root: String = GLTF_PREFIX_ANIMATED + "Disallowed_Clashing_Deep_Tree_3"
	if not _check_animated(original, expected_root):
		return false

	original = GLTF_PREFIX_ANIMATED + GLTF_DISALLOWED_CLASHING_DEEP_TREE_2
	var expected_mid = (expected_root + "/" +
		GLTF_PREFIX_ANIMATED + "Disallowed_Clashing_Deep_Tree_2")
	if not _check_animated(original, expected_mid):
		return false

	original = GLTF_PREFIX_ANIMATED + GLTF_DISALLOWED_CLASHING_DEEP_TREE_3
	var expected_leaf = (expected_mid + "/" +
		GLTF_PREFIX_ANIMATED + "Disallowed_Clashing_Deep_Tree_")
	return _check_animated(original, expected_leaf)
