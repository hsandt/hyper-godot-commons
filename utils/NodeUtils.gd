class_name NodeUtils
## Util static functions for general nodes


## Call queue free on all children of node
static func queue_free_children(node: Node):
	for child in node.get_children():
		child.queue_free()


## Instantiate a packed scene under a parent
## In editor and debug exports, force readable name (slow operation)
static func instantiate_under(packed_scene: PackedScene, parent: Node) -> Node:
	var instance := packed_scene.instantiate()
	parent.add_child(instance, OS.has_feature("debug"))
	return instance


## Instantiate a packed scene under a parent at a global position
## In editor and debug exports, force readable name (slow operation)
static func instantiate_under_at(packed_scene: PackedScene, parent: Node, global_position: Vector2) -> Node:
	var instance := packed_scene.instantiate()
	parent.add_child(instance, OS.has_feature("debug"))
	return instance


## Instantiate a packed scene under a parent at a global position at end of current frame
## In editor and debug exports, force readable name (slow operation)
static func instantiate_under_at_deferred(packed_scene: PackedScene, parent: Node, global_position: Vector2) -> Node:
	var instance := packed_scene.instantiate()
	parent.add_child.call_deferred(instance, OS.has_feature("debug"))
	instance.global_position = global_position
	return instance
