extends GutTest


const test_empty_scene2d = preload("res://addons/hyper-godot-commons/test/scenes/test_empty_scene2d.tscn")


func test_queue_free_children():
	# Create intermediate parent to call `queue_free_children` on, this GutTest instance `self` uses
	# an Awaiter node that we must absolutely not free to avoid error:
	# "Attempt to call function 'queue_free' in base 'previously freed' on a null instance."
	var parent := Node2D.new()
	add_child_autofree(parent)
	
	var node1 := Node2D.new()
	var node2 := Node2D.new()
	parent.add_child(node1)
	parent.add_child(node2)

	NodeUtils.queue_free_children(parent)
		
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

func test_set_flip_x_false():
	var node := Node2D.new()
	add_child_autofree(node)

	NodeUtils.set_flip_x(node, false)

	assert_eq(node.scale.y, 1.0)
	assert_eq(node.rotation, 0.0)
	assert_eq(node.rotation_degrees, 0.0)

func test_set_flip_x_true():
	var node := Node2D.new()
	add_child_autofree(node)

	NodeUtils.set_flip_x(node, true)

	assert_eq(node.scale.y, -1.0)
	assert_almost_eq(node.rotation, PI, 1e-7)
	assert_eq(node.rotation_degrees, 180.0)
