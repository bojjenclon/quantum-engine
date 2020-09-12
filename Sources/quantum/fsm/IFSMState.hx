package quantum.fsm;

@:allow(quantum.fsm.FSM)
interface IFSMState<T>
{
	private var _fsm : FSM<T>;
	private var _owner : T;

	public function update(dt : Float) : Void;

	private function onEnterState(from : IFSMState<T>) : Void;

	private function onExitState(to : IFSMState<T>) : Void;
}
