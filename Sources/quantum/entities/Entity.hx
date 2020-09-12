package quantum.entities;

import signals.Signal3;
import differ.data.ShapeCollision;
import quantum.scene.Scene;
import quantum.debug.KhaDrawer;
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
import signals.Signal2;
import signals.Signal1;

class Entity extends Basic implements IUpdateable implements IRenderable implements ICollideable
{
	public final onChildAdded : Signal1<Entity> = new Signal1<Entity>();
	public final onChildRemoved : Signal1<Entity> = new Signal1<Entity>();
	public final onCollisionEnter : Signal3<Shape, Shape, ShapeCollision> = new Signal3<Shape, Shape, ShapeCollision>();
	public final onCollisionExit : Signal2<Shape, Shape> = new Signal2<Shape, Shape>();

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
	var _isColliding : Array<ICollideable> = [];

	/**
	 * Determines if this entity can be pushed by collisions.
	 */
	public var immobile : Bool = false;

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
			renderDebug(g);
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
	function renderDebug(g : Graphics)
	{
		drawColliders(g);
	}

	function drawColliders(g : Graphics)
	{
		var shapeDrawer = KhaDrawer.drawer;
		shapeDrawer.g = g;

		g.color = Color.Red;

		for (shape in colliders)
		{
			var isColliding = shape.tags.exists("colliding");
			g.color = isColliding ? Color.White : Color.Red;
			shapeDrawer.drawShape(shape);
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

		syncColliders();
		checkCollision();

		updateChildren(dt);
	}

	function syncColliders()
	{
		for (collider in _colliders)
		{
			var offset = collider.data.offset;

			collider.x = globalX + offset.x;
			collider.y = globalY + offset.y;
			collider.scaleX = trueScale.x;
			collider.scaleY = trueScale.y;
			collider.rotation = trueRotation;
		}
	}

	function checkCollision()
	{
		for (collider in colliders)
		{
			#if debug
			var foundCollision = false;
			#end

			for (collideable in scene.collideables)
			{
				if (collideable == this)
				{
					continue;
				}

				var alreadyColliding = _isColliding.indexOf(collideable) > -1;
				var didEnter = false;
				var didExit = false;

				for (other in collideable.colliders)
				{
					var result = collider.test(other);
					var hasCollision = result != null;

					if (hasCollision)
					{
						#if debug
						if (!foundCollision)
						{
							collider.tags.set("colliding", "colliding");
							foundCollision = true;
						}
						#end

						var isTrigger = collider.tags.exists("trigger");
						if (!immobile && !isTrigger)
						{
							separate(result);
						}

						if (!alreadyColliding && !didEnter)
						{
							_isColliding.push(collideable);

							onCollisionEnter.dispatch(collider, other, result);
							didEnter = true;
						}
					}
					else
					{
						#if debug
						if (!foundCollision)
						{
							collider.tags.remove("colliding");
						}
						#end

						if (alreadyColliding && !didExit)
						{
							_isColliding.remove(collideable);

							onCollisionExit.dispatch(collider, other);
							didExit = true;
						}
					}
				}
			}
		}
	}

	function separate(collision : ShapeCollision)
	{
		x += collision.separationX;
		y += collision.separationY;

		syncColliders();
	}

	function updateChildren(dt : Float)
	{
		for (child in children)
		{
			child.update(dt);
		}
	}

	public function addChild(child : Entity) : Entity
	{
		child.parent = this;

		children.push(child);

		onChildAdded.dispatch(child);

		return child;
	}

	public function removeChild(child : Entity) : Entity
	{
		child.parent = null;

		children.remove(child);

		onChildRemoved.dispatch(child);

		return child;
	}

	override public function onAddedToScene(scene : Scene)
	{
		super.onAddedToScene(scene);

		for (child in children)
		{
			child.onAddedToScene(scene);
		}
	}

	override public function onRemovedFromScene(scene : Scene)
	{
		super.onRemovedFromScene(scene);

		for (child in children)
		{
			child.onRemovedFromScene(scene);
		}
	}

	public function addCollider(collider : Shape) : Shape
	{
		collider.data = {
			owner: this,
			offset: {
				x: collider.x,
				y: collider.y
			}
		};

		collider.x += globalX;
		collider.y += globalY;

		_colliders.push(collider);

		return collider;
	}

	public function addTrigger(trigger : Shape) : Shape
	{
		trigger.tags.set("trigger", "trigger");

		return addCollider(trigger);
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
