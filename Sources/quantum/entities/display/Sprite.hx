package quantum.entities.display;

import kha.math.FastVector2;
import kha.graphics2.Graphics;
import kha.Assets;
import kha.Image;
import quantum.entities.display.IRenderable;

class Sprite extends Entity
{
	public var width(get, never) : Int;
	public var height(get, never) : Int;

	public var scaledWidth(get, never) : Float;
	public var scaledHeight(get, never) : Float;

	var _image : Image;

	public function new(imageName : String)
	{
		_image = Assets.images.get(imageName);
	}

	override public function render(g : Graphics)
	{
		if (!visible)
		{
			return;
		}

		var center = new FastVector2(scaledWidth / 2, scaledHeight / 2);
		var rad = Math.PI / 180 * trueRotation;

		g.pushRotation(rad, globalX + center.x, globalY + center.y);
		g.pushOpacity(trueAlpha);

		renderSelf(g);

		g.popOpacity();
		g.popTransformation();

		renderChildren(g);
	}

	function renderSelf(g : Graphics)
	{
		g.drawScaledImage(_image, globalX, globalY, scaledWidth, scaledHeight);
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
		return width * trueScale.x;
	}

	function get_scaledHeight() : Float
	{
		return height * trueScale.y;
	}
}