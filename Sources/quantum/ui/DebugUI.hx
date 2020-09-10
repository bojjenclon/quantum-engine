package quantum.ui;

import signals.Signal1;
import zui.Id;

class DebugUI extends BaseUI
{
	public var onDebugDrawCheckChanged : Signal1<Bool> = new Signal1<Bool>();

	var _debugDrawCheck = Id.handle();

	public function new()
	{
		super();
	}

	override function generateUI()
	{
		if (ui.window(_hwin, 10, 10, 500, 200, true))
		{
			if (ui.panel(Id.handle({selected: true}), "Panel"))
			{
				ui.indent();

				var debugDragValue = ui.check(_debugDrawCheck, "Debug Draw");
				if (_debugDrawCheck.changed)
				{
					onDebugDrawCheckChanged.dispatch(debugDragValue);
				}

				ui.unindent();
			}
		}
	}
}
