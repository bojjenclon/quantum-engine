package quantum.ui;

import zui.Id;

class DebugUI extends BaseUI
{
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

				ui.check(_debugDrawCheck, "Debug Draw");
				if (_debugDrawCheck.changed)
				{
					trace("Debug draw not implemented");
				}

				ui.unindent();
			}
		}
	}
}
