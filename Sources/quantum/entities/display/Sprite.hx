package quantum.entities.display;

import differ.shapes.Shape;
import kha.Color;
import kha.math.FastVector2;
import kha.graphics2.Graphics;
import kha.Assets;
import kha.Image;

class Sprite extends Entity
{
	public var width(get, never) : Int;
	public var height(get, never) : Int;

	public var scaledWidth(get, never) : Float;
	public var scaledHeight(get, never) : Float;

	var _image : Image;

	public function new(image : Image)
	{
		super();

		_image = image;
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
		g.color = color;

		renderSelf(g);

		g.color = Color.White;
		g.popOpacity();
		g.popTransformation();

		#if debug
		var engine = QuantumEngine.engine;
		if (engine.debugDraw)
		{
			renderDebug(g);
		}
		#end

		renderChildren(g);
	}

	function renderSelf(g : Graphics)
	{
		g.drawScaledImage(_image, globalX, globalY, scaledWidth, scaledHeight);
	}

	override function syncColliders()
	{
		if (!_isDirty)
		{
			return;
		}
		
		super.syncColliders();

		for (collider in _colliders)
		{
			var shape = collider.shape;
			var offset = shape.data.offset;

			shape.x = globalX + scaledWidth / 2 + offset.x;
			shape.y = globalY + scaledHeight / 2 + offset.y;
		}
	}

	override public function addCollider(shape : Shape) : Shape
	{
		shape.data = {
			offset: {
				x: shape.x,
				y: shape.y
			}
		};

		shape.x += globalX + scaledWidth / 2;
		shape.y += globalY + scaledHeight / 2;

		var collider = new Collider(this, shape);
		_colliders.push(collider);

		return shape;
	}

	override public function serialize() : String
	{
		var buf = new StringBuf();

		buf.add(super.serialize());

		buf.add(',Width=$width');
		buf.add(',Height=$height');

		return buf.toString();
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
