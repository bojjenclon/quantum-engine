package quantum.ui;

import kha.Font;
import zui.Id;
import kha.Assets;
import zui.Zui;
import kha.graphics2.Graphics;

class BaseUI implements IUI
{
	public var visible(default, set) : Bool = false;
	public var ui(default, null) : Zui;

	var _windows : Array<Dynamic> = [];

	private function new(font : Font)
	{
		ui = new Zui({
			font: font,
			autoNotifyInput: false
		});
	}

	function onMouseWheel(wheel : Float) {}

	public function render(g : Graphics)
	{
		if (!visible)
		{
			return;
		}

		ui.begin(g);
		generateUI();
		ui.end();
	}

	function generateUI() {}

	public function scale(scale : Float)
	{
		ui.setScale(scale);

		// Force redraw
		for (hwin in _windows)
		{
			hwin.redraws = 1;
		}
	}

	function set_visible(value : Bool) : Bool
	{
		if (value)
		{
			ui.registerInput();
		}
		else
		{
			ui.unregisterInput();
		}

		return visible = value;
	}
}
