package quantum.ui;

import zui.Id;
import kha.Assets;
import zui.Zui;
import kha.graphics2.Graphics;

class BaseUI implements IUI
{
	public var visible(default, set) : Bool = false;
	public var ui(default, null) : Zui;

	var _hwin : Dynamic;

	private function new()
	{
		ui = new Zui({
			font: Assets.fonts._8_bit_hud,
			autoNotifyInput: false
		});

		_hwin = Id.handle();
	}

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
		_hwin.redraws = 1;
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
