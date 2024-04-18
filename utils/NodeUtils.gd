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
	instance.global_position = global_position
	return instance


## Instantiate a packed scene under a parent at a global position at end of current frame
## In editor and debug exports, force readable name (slow operation)
static func instantiate_under_at_deferred(packed_scene: PackedScene, parent: Node, global_position: Vector2) -> Node:
	var instance := packed_scene.instantiate()
	parent.add_child.call_deferred(instance, OS.has_feature("debug"))
	instance.global_position = global_position
	return instance


## Set the flip X state of passed node by setting transform parameters accordingly
## This function is idempotent, so calling it twice on the same node with flip: true
## will just flip it once.
static func set_flip_x(node: Node2D, flip: bool) -> void:
	if flip:
		# To avoid repeated flips when calling this function multiple times with flip: true,
		# we make sure to change scale.y instead of scale.x, and adjust rotation accordingly
		# https://godotengine.org/qa/92282/why-my-character-scale-keep-changing?show=146969#a146969
		node.scale.y = -1.0
		node.rotation = PI
	else:
		node.scale.y = 1.0
		node.rotation = 0.0
