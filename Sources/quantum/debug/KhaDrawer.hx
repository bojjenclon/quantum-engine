package quantum.debug;

#if debug
import kha.graphics2.Graphics;
import differ.ShapeDrawer;

class KhaDrawer extends ShapeDrawer
{
	public static final drawer : KhaDrawer = new KhaDrawer();

	public var g : Graphics;

	private function new()
	{
		super();
	}

	override public function drawLine(p0x : Float, p0y : Float, p1x : Float, p1y : Float, ?startPoint : Bool = true)
	{
		g.drawLine(p0x, p0y, p1x, p1y);
	}
}
#end
