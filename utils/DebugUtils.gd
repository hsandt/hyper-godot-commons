class_name DebugUtils
## Util static functions for debugging


## Assert that member is set on context
static func assert_member_is_set(context: Node, member: Object, member_name: String):
	assert(member, "%s: member '%s' is not set" % [context.get_path(), member_name])

## Assert that string member is not empty on context
static func assert_string_member_is_not_empty(context: Node, member: String, member_name: String):
	assert(!member.is_empty(), "%s: string member '%s' is empty" % [context.get_path(), member_name])

## Assert that array member is not empty on context
static func assert_array_member_is_not_empty(context: Node, member: Array, member_name: String):
	assert(!member.is_empty(), "%s: array member '%s' is empty" % [context.get_path(), member_name])
