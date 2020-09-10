package quantum.entities;

import quantum.entities.display.IRenderable;
import kha.graphics2.Graphics;
import kha.math.FastVector2;
import kha.math.Vector2;
import signals.Signal1;

class Entity extends Basic implements IUpdateable implements IRenderable
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

	public var rotation(default, set) : Float = 0;
	public var alpha(default, set) : Float = 1;
	public var scale : FastVector2 = new FastVector2(1, 1);

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

		renderChildren(g);
	}

	function renderChildren(g : Graphics)
	{
		for (child in children)
		{
			child.render(g);
		}
	}

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
}
