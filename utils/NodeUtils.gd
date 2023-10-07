class_name NodeUtils


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


## Return the absolute Z index of a Node2D
static func get_absolute_z_index(target: Node2D) -> int:
	# Thanks to Bruno Ely
	# See https://godotengine.org/qa/46915/getting-the-absolute-z-index-of-a-node
	var node = target;
	var z_index = 0;
	while node and node.is_class('Node2D'):
		z_index += node.z_index;
		if !node.z_as_relative:
			break;
		node = node.get_parent();
	return z_index;
