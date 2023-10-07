class_name DebugUtils


## Assert that member is set on context
static func assert_member_is_set(context: Node, member: Object, member_name: String):
	assert(member, "%s: %s is not set" % [context.get_path(), member_name])
