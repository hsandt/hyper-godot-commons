class_name NextFiniteStateQuery


## Next state to query
var next_state_name: String

## Priority of the query
## This is useful when multiple queries are sent on the same frame, to select the one
## with the highest priority. In case of draw, the earliest in the array of queries will be selected.
var priority: int

## (Debug-only) Callstack to find where the query was sent
## This is useful as breakpoint won't show the context of query sent on previous frame
var debug_callstack: Array


func _init(p_next_state_name: String, p_priority: int, p_debug_callstack: Array):
	next_state_name = p_next_state_name
	priority = p_priority
	debug_callstack = p_debug_callstack


## Return a simplified string representation of this query,
## only showing the most relevant line of callstack (if any)
func to_simplified_string() -> String:
	var most_relevant_debug_callstack_string: String
	if debug_callstack.size() >= 2:
		# The first debug callstack line is always the line calling `get_stack()` inside
		# FiniteStateMachine.set_next_state_by_name which is not relevant, so pick the second element
		var most_relevant_debug_callstack_info: Dictionary = debug_callstack[1]
		most_relevant_debug_callstack_string = "%s:%d @ %s()" % [
				most_relevant_debug_callstack_info["source"],
				most_relevant_debug_callstack_info["line"],
				most_relevant_debug_callstack_info["function"]
			]
	else:
		most_relevant_debug_callstack_string = "UNKNOWN"

	# For the callstack line, mimic Godot's debugger line format
	return "NextFiniteStateQuery('%s', %d) from %s" % \
		[next_state_name, priority, most_relevant_debug_callstack_string]
