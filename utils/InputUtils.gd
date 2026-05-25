class_name InputUtils
## Util static functions for input


## Return true iff matches passed input event exactly (no difference in modifiers)
## and is being pressed without echo
## Error if action is not defined in input map
static func is_exact_action_pressed_by_event(event: InputEvent, action: StringName):
	return event.is_action_pressed(action, false, true)


## Return true iff action is defined in input map, matches passed input event
## exactly (no difference in modifiers) and is being pressed without echo
static func is_exact_action_defined_and_pressed_by_event(event: InputEvent, action: StringName):
	return InputMap.has_action(action) and is_exact_action_pressed_by_event(event, action)
