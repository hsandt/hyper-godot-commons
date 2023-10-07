class_name NodeUtils
## Util static functions for general nodes


## Call queue free on all children of node
static func queue_free_children(node: Node):
	for child in node.get_children():
		child.queue_free()


## Instantiate a packed scene under a parent
static func instantiate_under(packed_scene: PackedScene, parent: Node) -> Node:
	var instance := packed_scene.instantiate()
	parent.add_child(instance)
	return instance


## Instantiate a packed scene under a parent at a global position
static func instantiate_under_at(packed_scene: PackedScene, parent: Node, global_position: Vector2) -> Node:
	var instance := packed_scene.instantiate()
	parent.add_child(instance)
	instance.global_position = global_position
	return instance
