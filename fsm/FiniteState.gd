class_name FiniteState
extends Node
## Base class for a State for a Finite State Machine (FSM)


## Signal emitted when state is entered
signal entered

## Signal emitted when state is exited
signal exited


# Dynamic parameters

## Owning finite state machine
## Set on state machine initialization
var state_machine: FiniteStateMachine

## Owning entity
## Rarely useful by itself, we recommend to define a derived class
## of FiniteState with its own owner member with a specific type
## then override on_set_owner_entity to cast _owner_entity into that member
## Set on state machine initialization
var _owner_entity: Node


func set_owner_entity(p_owner_entity: Node):
	_owner_entity = p_owner_entity
	on_set_owner_entity(p_owner_entity)


# virtual
## This method only exists to allow derived classes to cast the generic
## owner entity node into a cached owner variable with a specific type
func on_set_owner_entity(_p_owner_entity: Node):
	pass


func enter():
	entered.emit()
	on_enter()


func exit():
	exited.emit()
	on_exit()


# abstract
func get_state_name() -> StringName:
	push_error("not implemented on '%s'" % get_path())
	return &""


# abstract
## Return base animation to play while this action is running
## Note that since states have their own start/interrupt/complete system,
## using this with base animation supersedes the override animation system,
## which is not needed for Finite States
func get_base_animation() -> StringName:
	push_error("not implemented on '%s'" % get_path())
	return &""


# virtual
## Return the list of tags that are activated while this action is running
func get_tags() -> Array[StringName]:
	return []


# virtual
## Return the list of attribute modifiers that are activated while this action is running
func get_attribute_modifiers() -> Array[AttributeModifier]:
	return []


# virtual
## Called when state is initialized from the state machine, so that owner member
## is guaranteed to be defined
func on_initialize():
	pass


# virtual
## Called when state is entered
func on_enter():
	pass


# abstract
## Custom action on_physics_process when override_move returns true
## Only needs implementation if override_move may return true
func on_physics_process(_delta: float):
	push_error("not implemented on '%s', " % get_path(),
		"make sure to override it on child class when override_move returns true")


# virtual
## Called when state is exited
func on_exit():
	pass


# virtual
## Called when changing state from this state to new_state (between this state's on_exit
## and new state's on_enter)
func on_transition_to(_new_state: FiniteState):
	pass
