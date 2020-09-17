package quantum.partials;

import kha.graphics2.Graphics;

interface IRenderable
{
	public var priority : Int;
	
	public function render(g : Graphics) : Void;
}
