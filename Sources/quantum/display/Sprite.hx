package quantum.display;

import kha.math.FastMatrix3;
import kha.math.FastVector2;
import kha.math.Vector2;
import kha.graphics2.Graphics;
import kha.Assets;
import kha.Image;
import quantum.display.IRenderable;

class Sprite implements IRenderable
{
	public var position : Vector2 = new Vector2(0, 0);
	public var x(get, set) : Float;
	public var y(get, set) : Float;
	public var width(get, never) : Int;
	public var height(get, never) : Int;
	public var scaledWidth(get, never) : Float;
	public var scaledHeight(get, never) : Float;
	public var rotation(default, set) : Float = 0;
	public var alpha(default, set) : Float = 1;
	public var scale : FastVector2 = new FastVector2(1, 1);

	var _image : Image;

	public function new(imageName : String)
	{
		_image = Assets.images.get(imageName);
	}

	public function render(g : Graphics)
	{
		var center = new FastVector2(scaledWidth / 2, scaledHeight / 2);
		var rad = Math.PI / 180 * rotation;

		g.pushRotation(rad, x + center.x, y + center.y);
		g.pushOpacity(alpha);

		g.drawScaledImage(_image, x, y, scaledWidth, scaledHeight);

		g.popOpacity();
		g.popTransformation();
	}

	function get_x() : Float
	{
		return position.x;
	}

	function set_x(value : Float) : Float
	{
		return position.x = value;
	}

	function get_y() : Float
	{
		return position.y;
	}

	function set_y(value : Float) : Float
	{
		return position.y = value;
	}

	function get_width() : Int
	{
		return _image.width;
	}

	function get_height() : Int
	{
		return _image.height;
	}

	function get_scaledWidth() : Float
	{
		return width * scale.x;
	}

	function get_scaledHeight() : Float
	{
		return height * scale.y;
	}

	function set_rotation(value : Float) : Float
	{
		return rotation = value % 360;
	}

	function set_alpha(value : Float) : Float
	{
		alpha = value;

		if (alpha < 0)
		{
			alpha = 0;
		}
		else if (alpha > 1)
		{
			alpha = 1;
		}

		return alpha;
	}
}
