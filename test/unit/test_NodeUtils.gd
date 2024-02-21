extends GutTest


const test_empty_scene2d = preload("res://addons/hyper-godot-commons/test/scenes/test_empty_scene2d.tscn")


func test_instantiate_under_at():
	var instance := NodeUtils.instantiate_under_at(test_empty_scene2d, get_tree().root, Vector2(1.0, 2.0))
	assert_eq(instance.global_position, Vector2(1.0, 2.0))
