package quantum.fsm;

import haxe.ds.StringMap;

class FSM<T>
{
	public var owner(default, null) : T;
	public var state(default, null) : IFSMState<T>;

	var _states : StringMap<IFSMState<T>> = new StringMap<IFSMState<T>>();

	public function new(owner : T)
	{
		this.owner = owner;
	}

	public function add(state : IFSMState<T>)
	{
		state._fsm = this;
		state._owner = owner;

		_states.set(state.name, state);
	}

	public function goto(name : String)
	{
		if (!_states.exists(name))
		{
			return;
		}

		var prevState = state;
		var nextState = _states.get(name);

		if (prevState != null)
		{
			prevState.onExitState(nextState);
		}

		state = nextState;
		state.onEnterState(prevState);
	}
}
