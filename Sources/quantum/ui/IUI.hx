package quantum.ui;

import zui.Zui;
import kha.graphics2.Graphics;

interface IUI
{
	public var visible : Bool;
	public var ui(default, null) : Zui;

	public function render(g : Graphics) : Void;
	public function scale(scale : Float) : Void;
}
