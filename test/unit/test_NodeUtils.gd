extends GutTest


const test_empty_scene2d = preload("res://addons/hyper-godot-commons/test/scenes/test_empty_scene2d.tscn")


func test_queue_free_children():
	var node1 := Node2D.new()
	var node2 := Node2D.new()
	add_child_autofree(node1)
	add_child_autofree(node2)

	# Since add_child_autofree add nodes to self (the test node),
	# pass self to queue_free_children
	# (never work directly on root node, since GutRunner is a child of root)
	NodeUtils.queue_free_children(self)

	assert_true(node1.is_queued_for_deletion())
	assert_true(node2.is_queued_for_deletion())

func test_instantiate_under():
	var instance := NodeUtils.instantiate_under(test_empty_scene2d, get_tree().root)
	autofree(instance)

	assert_eq(instance.get_parent(), get_tree().root)

func test_instantiate_under_at():
	var instance := NodeUtils.instantiate_under_at(test_empty_scene2d, get_tree().root, Vector2(1.0, 2.0))
	autofree(instance)

	assert_eq(instance.get_parent(), get_tree().root)
	assert_eq(instance.global_position, Vector2(1.0, 2.0))

func test_instantiate_under_at_deferred():
	var instance := NodeUtils.instantiate_under_at_deferred(test_empty_scene2d, get_tree().root, Vector2(1.0, 2.0))
	autofree(instance)

	assert_eq(instance.global_position, Vector2(1.0, 2.0))
	await get_tree().physics_frame
	assert_eq(instance.get_parent(), get_tree().root)
