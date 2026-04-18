class_name FiniteStateMachine
extends Node
## Finite State Machine (FSM) component
##
## Usage:
## - Add it under an owner entity node and reference it as state_machine
## - In owner entity script, call state_machine.initialize() once on start,
##   and state_machine.setup() on start and on every reset
## - In owner entity script's _physics_process(), call state_machine._check_next_state()
##   to apply change state request, then call state_machine.on_physics_process(delta)
##   to process the current state
## - Create derived classes of FiniteState to define state behaviors,
##   and add instances of them under this node
## - Call change_state_by_name to set the initial state, then later,
##   call change_state_by_name, set_next_state_by_name or any variant
##   to change state immediately or on next frame


# Dynamic parameters

## Owning entity
## Set on state machine initialization
var owner_entity: Node

## Dictionary of state name: StringName => state: FiniteState
var states_dict: Dictionary#<StringName, FiniteState>

## Base attributes dictionary
## Filled in initialize from @export variables
var base_attributes := {}

# State

## Current state
var current_state: FiniteState

## Array of queries for state to start on next frame, if any (null to keep same state as before)
## If several queries are sent on the same frame, the one with highest priority will be selected
## In case of draw, the earliest in the array will be selected
var next_state_queries: Array[NextFiniteStateQuery]

## List of tags currently active
## Tags are added by states on start, and removed on finally
var active_tags: Array[StringName]

## List of attribute modifiers currently active
## Attribute modifiers are added by states on start, and removed on finally
var active_attribute_modifiers: Array[AttributeModifier]

## Current attributes dictionary
## Initialized with base_attributes and updated with Action attribute modifiers at runtime
var current_attributes := {}


func initialize(p_owner_entity: Node):
	# States
	for child in get_children():
		var state := child as FiniteState
		if not state:
			push_error("child '%s' is under a FiniteStateMachine node, yet not a FiniteState" % child.get_path())
			continue

		# Assign this state machine and owner entity to state and store in dict
		# so it's accessible by its name identifier
		state.state_machine = self
		state.set_owner_entity(p_owner_entity)
		states_dict[state.get_state_name()] = state

		# Now that owner reference has been set, we can safely initialize the states
		state.on_initialize()


func setup():
	# Instead of setting the current state, set the next state to make sure that
	# State enter logic is applied to the initial state
	current_state = null
	next_state_queries.clear()

	# Merge base attributes into current attributes with overwrite:
	# - on first deferred_setup, this will effectively copy base attributes
	# - on further deferred_setup calls, this will reset all current attributes
	current_attributes.merge(base_attributes, true)


func clear():
	# Tags and attributes
	active_tags.clear()
	active_attribute_modifiers.clear()


func on_physics_process(delta: float):
	if current_state != null:
		current_state.on_physics_process(delta)


## Return state with passed name
func get_state_by_name(state_name: StringName) -> FiniteState:
	var state = states_dict.get(state_name) as FiniteState

	if not state:
		push_error("%s: state_name '%s' is not in states_dict keys" %
			[get_path(), state_name])

	return state


## Instantly change state by name and return new state
## If allow_restart is true, allow setting the same state as current state (it will be restarted)
## Else, do nothing else and warn if already in target state
func change_state_by_name(next_state_name: StringName, allow_restart: bool = false) -> FiniteState:
	var stored_next_state := set_next_state_by_name(next_state_name, allow_restart)

	# just in case next_state was already set, check stored_next_state
	# to make sure that this is the last call to set_next_state_by_name that set it
	if stored_next_state:
		_check_next_state()

	return stored_next_state


## Similar to change_state_by_name, but assume allow_restart = false and
## don't warn if trying to set the same state again, just do nothing
func try_change_state_by_name_without_restart(next_state_name: StringName):
	if get_current_state_name() == next_state_name:
		return

	change_state_by_name(next_state_name, false)


## Set the state to start on next frame by name and return true iff state was found
## If allow_restart is true, allow setting the same state as current state (it will be restarted on next frame)
## Else, do nothing else and warn if already in target state
## Priority is used in case of multiple next state queries in a single frame
## In case of draw (same priority), the earliest call (lowest index in query array) will be considered on next frame
## Setting next state multiple times in a row is not supported (you must wait for next frame to set next state again)
func set_next_state_by_name(next_state_name: StringName, allow_restart: bool = false, priority: int = 0) -> FiniteState:
	var found_next_state = states_dict.get(next_state_name) as FiniteState

	if not found_next_state:
		push_error("%s: next_state_name '%s' is not in states_dict keys. STOP." %
			[get_path(), next_state_name])
		return null

	if current_state == found_next_state and not allow_restart:
		push_warning("%s: already in state '%s' and allow_restart is false. STOP." %
				[get_path(), next_state_name])
		return null

	if next_state_queries and priority == 0:
		push_warning("%s: set_next_state_by_name('%s', %s, 0): next_state_queries already contains '%d' entrie(s) with state names:\n%s\n" %
				[get_path(), next_state_name, allow_restart, next_state_queries.size(),
					next_state_queries.map(func(query: NextFiniteStateQuery): return query.to_simplified_string())],
			"but priority is 0. Consider setting a priority to avoid relying on query order. ")

	var callstack := get_stack() if OS.has_feature("debug") else []
	var next_state_query = NextFiniteStateQuery.new(next_state_name, priority, callstack)
	next_state_queries.append(next_state_query)
	return found_next_state


## Similar to set_next_state_by_name, but assume allow_restart = false and
## don't warn if trying to set the same state again, just do nothing
func try_set_next_state_by_name_without_restart(next_state_name: StringName):
	if get_current_state_name() == next_state_name:
		return

	set_next_state_by_name(next_state_name, false)


## If next state queries are present is set, clear all queries and change to state with highest priority
func _check_next_state():
	if not next_state_queries:
		return

	# Find the next state query with the highest priority
	var selected_query: NextFiniteStateQuery = null

	# In 99% of the cases, there is only one query per frame, so don't waste
	# time with sorting and just pick that query
	if next_state_queries.size() == 1:
		selected_query = next_state_queries[0]
	else:
		# Else we sort queries by priority > ascending order in Array
		var max_priority_found: int = MathConstants.INT64_MIN
		for query in next_state_queries:
			# strict < comparison: if same priority, earlier Array entry is prior
			if max_priority_found < query.priority:
				max_priority_found = query.priority
				selected_query = query
		if not selected_query:
			push_error("%s: no query had priority > MathConstants.INT64_MIN, STOP" % get_path())
			return

	var found_next_state = states_dict.get(selected_query.next_state_name) as FiniteState

	# Clear queries before _change_state since the latter may add more queries
	# in case of immediate chained transitions, which we don't want to clear
	next_state_queries.clear()

	_change_state(found_next_state)


## Change state behavior (can go from and to null)
func _change_state(new_state: FiniteState):
	if current_state:
		current_state.exit()
		remove_state_tags_and_attribute_modifiers(current_state)
		current_state.on_transition_to(new_state)

	#var old_state := current_state
	current_state = new_state

	current_state.on_enter()
	add_state_tags_and_attribute_modifiers(current_state)

	# DISABLED after refactoring to extract FiniteStateMachine
	# because we don't have access to animation_controller,
	# and in this game, any state that needs to replay base animation
	# does it in on_enter anyway
	#if old_state == new_state:
		# We only allow transitioning to the same state when we explicitly want to restart
		# that state (calling set_next_state_by_name with allow_restart = true),
		# so replay animation from start
		#var action_base_animation := current_state.get_base_animation()
		#animation_controller.play_animation(action_base_animation)

	return current_state


func has_active_tag(tag: StringName) -> bool:
	return tag in active_tags


func add_active_tag(tag: StringName):
	var tag_index := active_tags.find(tag)
	if tag_index >= 0:
		push_warning("%s: tag '%s' is already active, " % [get_path(), tag],
			"so we are not re-adding the tag to avoid unsupported redundant tags, STOP")
		return

	active_tags.append(tag)


func remove_active_tag(tag: StringName):
	var tag_index := active_tags.find(tag)
	if tag_index < 0:
		push_warning("%s: could not find tag '%s'" % [get_path(), tag])
		return

	# Note that an array is not the most performant data structure for set-like operations,
	# but it supports redundant tags without having to manually track tag count
	# Here, it will just erase the first tag it finds
	active_tags.remove_at(tag_index)


func try_remove_active_tag(tag: StringName):
	active_tags.erase(tag)


## Return current state name if any, empty StringName else
func get_current_state_name() -> StringName:
	if current_state:
		return current_state.get_state_name()
	else:
		# Rare, but may happen on first frame during initialization
		return &""


## Add all tags and attribute modifiers associated to passed state
func add_state_tags_and_attribute_modifiers(state: FiniteState):
	add_state_active_tags(state)
	add_state_attribute_modifiers(state)


## Remove all tags and attribute modifiers associated to passed state
func remove_state_tags_and_attribute_modifiers(state: FiniteState):
	remove_state_active_tags(state)
	remove_state_attribute_modifiers(state)


func add_state_active_tags(state: FiniteState):
	active_tags.append_array(state.get_tags())


func remove_state_active_tags(state: FiniteState):
	for tag in state.get_tags():
		# Note that an array is not the most performant data structure for set-like operations,
		# but it supports redundant tags without having to manually track tag count
		# Here, it will just erase the first tag it finds
		active_tags.erase(tag)


func add_state_attribute_modifiers(state: FiniteState):
	add_attribute_modifiers(state.get_attribute_modifiers())


func add_attribute_modifiers(attribute_modifiers: Array[AttributeModifier]):
	active_attribute_modifiers.append_array(attribute_modifiers)

	# Update all dirty attributes
	# Note: this is suboptimal when state contains multiple
	# attribute modifiers targeting the same attribute as only the final update
	# for this attribute will matter, but this is a rare case
	for attribute_modifier in attribute_modifiers:
		update_current_attribute(attribute_modifier.attribute_name)


func remove_state_attribute_modifiers(state: FiniteState):
	var attribute_modifiers := state.get_attribute_modifiers()
	for attribute_modifier in attribute_modifiers:
		active_attribute_modifiers.erase(attribute_modifier)

	# Update all dirty attributes
	# Note: this is suboptimal in rare case, see add_attribute_modifiers
	for attribute_modifier in attribute_modifiers:
		update_current_attribute(attribute_modifier.attribute_name)


func update_current_attribute(attribute_name: StringName):
	var final_multiplier := 1.0
	for active_attribute_modifier in active_attribute_modifiers:
		final_multiplier *= active_attribute_modifier.multiplier

	current_attributes[attribute_name] = final_multiplier * base_attributes[attribute_name]
