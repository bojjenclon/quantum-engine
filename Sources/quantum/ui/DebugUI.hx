package quantum.ui;

import signals.Signal1;
import zui.Id;

class DebugUI extends BaseUI
{
	public var onDebugDrawCheckChanged : Signal1<Bool> = new Signal1<Bool>();

	var _optionsWindow = Id.handle();
	var _statsWindow = Id.handle();
	var _debugDrawCheck = Id.handle();

	public function new()
	{
		super();

		_windows.push(_optionsWindow);
		_windows.push(_statsWindow);
	}

	override function generateUI()
	{
		var engine = QuantumEngine.engine;

		if (ui.window(_optionsWindow, 5, 5, 200, 200, true))
		{
			if (ui.panel(Id.handle({selected: true}), "Drawing"))
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

		_statsWindow.redraws = 1;
		if (ui.window(_statsWindow, engine.width - 125, 5, 120, 200, true))
		{
			var fpsString = '${engine.timer.fpsAvg}'.substring(0, 5);
			ui.text('FPS: $fpsString');
		}
	}
}
