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

	public function add(stateClass : Class<IFSMState<T>>)
	{
		state._fsm = this;
		state._owner = owner;

		var stateName = Type.getClassName(stateClass);
		_states.set(stateName, Type.createInstance(stateClass, []));
	}

	public function goto(stateClass : Class<IFSMState<T>>)
	{
		var stateName = Type.getClassName(stateClass);
		if (!_states.exists(stateName))
		{
			return;
		}

		var prevState = state;
		var nextState = _states.get(stateName);

		if (prevState != null)
		{
			prevState.onExitState(nextState);
		}

		state = nextState;
		state.onEnterState(prevState);
	}

	public function update(dt : Float)
	{
		if (state != null)
		{
			state.update(dt);
		}
	}
}
