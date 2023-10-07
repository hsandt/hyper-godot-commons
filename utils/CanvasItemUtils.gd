class_name CanvasItemUtils


## Return the absolute Z index of a CanvasItem
## If target is not a CanvasItem, return 0
static func get_absolute_z_index(target: CanvasItem) -> int:
	# Source: Bruno Ely's answer on https://ask.godotengine.org/46915/getting-the-absolute-z-index-of-a-node
	# Changes by hsandt:
	# - adapted to CanvasItem
	# - removed extraneous semicolon `;`
	var node = target
	var z_index = 0
	while node and node.is_class('CanvasItem'):
		z_index += node.z_index
		if !node.z_as_relative:
			break
		node = node.get_parent()
	return z_index
