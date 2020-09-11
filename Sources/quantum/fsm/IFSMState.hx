package quantum.fsm;

@:allow(FSM)
interface IFSMState<T>
{
	public final name : String;

	var _fsm : FSM<T>;
	var _owner : T;

	public function update(dt : Float) : Void;

	function onEnterState(from : IFSMState<T>) : Void;

	function onExitState(to : IFSMState<T>) : Void;
}
