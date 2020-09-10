package quantum.entities;

import differ.shapes.Polygon;
import differ.shapes.Circle;
import differ.shapes.Shape;
import haxe.ds.ReadOnlyArray;
import kha.Color;
import quantum.partials.IUpdateable;
import quantum.partials.IRenderable;
import quantum.partials.ICollideable;
import kha.graphics2.Graphics;
import kha.math.FastVector2;
import kha.math.Vector2;
import signals.Signal1;

class Entity extends Basic implements IUpdateable implements IRenderable implements ICollideable
{
	public final onChildAdded : Signal1<Entity> = new Signal1<Entity>();
	public final onChildRemoved : Signal1<Entity> = new Signal1<Entity>();

	/**
	 * Position relative to parent.
	 */
	public var position : Vector2 = new Vector2(0, 0);
	/**
	 * X-coord relative to parent.
	 */
	public var x(get, set) : Float;
	/**
	 * Y-coord relative to parent.
	 */
	public var y(get, set) : Float;

	/**
	 * Absolute position.
	 */
	public var globalPosition(get, never) : Vector2;
	/**
	 * Absolute x-coord.
	 */
	public var globalX(get, never) : Float;
	/**
	 * Absolute y-coord.
	 */
	public var globalY(get, never) : Float;

	/**
	 * This entity's rotation, independent of the parent's.
	 */
	public var rotation(default, set) : Float = 0;
	/**
	 * This entity's alpha, independent of the parent's.
	 */
	public var alpha(default, set) : Float = 1;
	/**
	 * This entity's scale, independent of the parent's.
	 */
	public var scale : FastVector2 = new FastVector2(1, 1);

	/**
	 * Rotation relative to parent.
	 */
	public var trueRotation(get, never) : Float;
	/**
	 * Alpha relative to parent.
	 */
	public var trueAlpha(get, never) : Float;
	/**
	 * Scale relative to parent.
	 */
	public var trueScale(get, never) : FastVector2;

	public var color : Color = Color.White;

	public var colliders(get, never) : ReadOnlyArray<Shape>;

	var _colliders : Array<Shape> = [];

	/**
	 * Determines if this entity will be updated.
	 */
	public var active : Bool = true;
	/**
	 * Determines if this entity will be rendered.
	 */
	public var visible : Bool = true;

	public var parent(default, null) : Entity;
	public var children : Array<Entity> = new Array<Entity>();

	public function render(g : Graphics)
	{
		if (!visible)
		{
			return;
		}

		#if debug
		var engine = QuantumEngine.engine;
		if (engine.debugDraw)
		{
			drawColliders(g);
		}
		#end

		renderChildren(g);
	}

	function renderChildren(g : Graphics)
	{
		for (child in children)
		{
			child.render(g);
		}
	}

	#if debug
	function drawColliders(g : Graphics)
	{
		g.color = Color.Red;

		for (shape in colliders)
		{
			if (Std.is(shape, Circle))
			{
				var circle = cast(shape, Circle);
				var radius = circle.transformedRadius;

				var segments = 20;
				var step = 2 * Math.PI / segments;
				// Start at the second point since our draw uses the
				// previous and current points for each line.
				var theta = step;

				while (theta <= 2 * Math.PI)
				{
					var x1 = circle.x + radius * Math.cos(theta - step);
					var y1 = circle.y + radius * Math.sin(theta - step);

					var x2 = circle.x + radius * Math.cos(theta);
					var y2 = circle.y + radius * Math.sin(theta);

					g.drawLine(x1, y1, x2, y2);

					theta += step;
				}
			}
			else if (Std.is(shape, Polygon))
			{
				var polygon = cast(shape, Polygon);
				var vertices = polygon.transformedVertices;

				for (i in 0...vertices.length)
				{
					var v1 = vertices[i];
					var v2 = vertices[(i + 1) % vertices.length];

					g.drawLine(v1.x, v1.y, v2.x, v2.y);
				}
			}
		}

		g.color = Color.Black;
	}
	#end

	public function update(dt : Float)
	{
		if (!active)
		{
			return;
		}

		updateChildren(dt);
	}

	function updateChildren(dt : Float)
	{
		for (child in children)
		{
			child.update(dt);
		}
	}

	public function addChild(child : Entity)
	{
		child.parent = this;

		children.push(child);

		onChildAdded.dispatch(child);
	}

	public function removeChild(child : Entity)
	{
		child.parent = null;

		children.remove(child);

		onChildRemoved.dispatch(child);
	}

	public function addCollider(collider : Shape)
	{
		_colliders.push(collider);
	}

	override public function serialize() : String
	{
		var buf = new StringBuf();

		buf.add(super.serialize());

		buf.add(',Position=($x, $y)');
		buf.add(',Rotation=$rotation');
		buf.add(',Alpha=$alpha');
		buf.add(',Scale=(${scale.x}, ${scale.y})');

		return buf.toString();
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

	function get_globalPosition() : Vector2
	{
		if (parent == null)
		{
			return position;
		}

		return new Vector2(parent.x + x, parent.y + y);
	}

	function get_globalX() : Float
	{
		if (parent == null)
		{
			return x;
		}

		return parent.x + x;
	}

	function get_globalY() : Float
	{
		if (parent == null)
		{
			return y;
		}

		return parent.y + y;
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

	function get_trueRotation() : Float
	{
		if (parent == null)
		{
			return rotation;
		}

		return parent.rotation + rotation;
	}

	function get_trueAlpha() : Float
	{
		if (parent == null)
		{
			return alpha;
		}

		return parent.alpha * alpha;
	}

	function get_trueScale() : FastVector2
	{
		if (parent == null)
		{
			return scale;
		}

		return new FastVector2(parent.scale.x * scale.x, parent.scale.y * scale.y);
	}

	function get_colliders() : ReadOnlyArray<Shape>
	{
		return _colliders;
	}
}
