extends GutTest


# Despite being a double, we register it as a FiniteStateMachine
# This allows us to use auto-completion and also assign typed array members
var fsm: FiniteStateMachine


func before_each():
	fsm = partial_double(FiniteStateMachine).new()


func test_check_next_state_given_no_next_state_queries_then_nothing():
	stub(fsm._change_state).to_do_nothing()

	fsm._check_next_state()

	assert_not_called(fsm, '_change_state')


func test_check_next_state_given_one_next_state_query_then_clear_queries_and_change_state():
	stub(fsm._change_state).to_do_nothing()

	var dummy_state: FiniteState = double(FiniteState).new()
	fsm.states_dict = {&"Dummy": dummy_state}
	fsm.next_state_queries = [NextFiniteStateQuery.new(&"Dummy", 0, [])]

	fsm._check_next_state()

	assert_eq(fsm.next_state_queries.size(), 0)
	assert_called(fsm, '_change_state', [dummy_state])


func test_check_next_state_given_two_next_state_queries_with_same_priority_then_clear_queries_and_change_state_to_first():
	stub(fsm._change_state).to_do_nothing()

	var dummy_state1: FiniteState = double(FiniteState).new()
	var dummy_state2: FiniteState = double(FiniteState).new()
	fsm.states_dict = {&"Dummy1": dummy_state1, &"Dummy2": dummy_state2}
	fsm.next_state_queries = [
		NextFiniteStateQuery.new(&"Dummy1", 0, []),
		NextFiniteStateQuery.new(&"Dummy2", 0, [])
	]

	fsm._check_next_state()

	assert_eq(fsm.next_state_queries.size(), 0)
	assert_called(fsm, '_change_state', [dummy_state1])


func test_check_next_state_given_two_next_state_queries_with_different_priorities_then_clear_queries_and_change_state_to_higher_priority():
	stub(fsm._change_state).to_do_nothing()

	var dummy_state1: FiniteState = double(FiniteState).new()
	var dummy_state2: FiniteState = double(FiniteState).new()
	fsm.states_dict = {&"Dummy1": dummy_state1, &"Dummy2": dummy_state2}
	fsm.next_state_queries = [
		NextFiniteStateQuery.new(&"Dummy1", 0, []),
		NextFiniteStateQuery.new(&"Dummy2", 1, [])
	]

	fsm._check_next_state()

	assert_eq(fsm.next_state_queries.size(), 0)
	assert_called(fsm, '_change_state', [dummy_state2])
