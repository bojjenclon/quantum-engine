package quantum.entities;

import kha.FastFloat;
import differ.data.ShapeCollision;
import differ.shapes.Circle;
import differ.shapes.Polygon;
import differ.shapes.Shape;
import haxe.ds.ReadOnlyArray;
import kha.Color;
import kha.graphics2.Graphics;
import kha.math.FastVector2;
import kha.math.FastVector2;
import quantum.debug.KhaDrawer;
import quantum.entities.Collider;
import quantum.partials.ICollideable;
import quantum.partials.IRenderable;
import quantum.partials.IUpdateable;
import quantum.scene.Scene;
import signals.Signal1;
import signals.Signal2;
import signals.Signal3;

class Entity extends Basic implements IUpdateable implements IRenderable implements ICollideable
{
	public final onChildAdded : Signal1<Entity> = new Signal1<Entity>();
	public final onChildRemoved : Signal1<Entity> = new Signal1<Entity>();
	public final onCollisionEnter : Signal3<Collider, Collider, ShapeCollision> = new Signal3<Collider, Collider, ShapeCollision>();
	public final onCollisionExit : Signal2<Collider, Collider> = new Signal2<Collider, Collider>();

	/**
	 * Position relative to parent.
	 */
	public var position : FastVector2 = new FastVector2(0, 0);
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
	public var globalPosition(get, never) : FastVector2;
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
	public var scale(default, set) : FastVector2 = new FastVector2(1, 1);
	public var scaleX(get, set) : FastFloat;
	public var scaleY(get, set) : FastFloat;

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

	public var colliders(get, never) : ReadOnlyArray<Collider>;

	var _colliders : Array<Collider> = [];
	var _isColliding : Array<ICollideable> = [];
	var _isDirty : Bool = true;

	/**
	 * Determines if this entity can be pushed by collisions.
	 */
	public var immobile(default, set) : Bool = false;

	/**
	 * Determines if this entity will be updated.
	 */
	public var active : Bool = true;

	/**
	 * Determines if this entity will be rendered.
	 */
	public var visible : Bool = true;

	/**
	 * Determines if this entity should respond to collision events.
	 */
	public var canCollide(default, set) : Bool = true;

	/**
	 * Determines if this entity should be added to the MapState's list of interactive objects.
	 */
	public var isInteractive : Bool = false;

	public var parent(default, set) : Entity;
	public var children : Array<Entity> = new Array<Entity>();

	public function new()
	{
		super();

		#if debug
		onCollisionEnter.add(function(collider : Collider, other : Collider, result : ShapeCollision)
		{
			if (collider._collidingWith.length == 1)
			{
				collider.shape.tags.set("colliding", "colliding");
			}
		});

		onCollisionExit.add(function(collider : Collider, other : Collider)
		{
			if (collider._collidingWith.length == 0)
			{
				collider.shape.tags.remove("colliding");
			}
		});
		#end
	}

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

		for (collider in colliders)
		{
			var shape = collider.shape;
			var isColliding = shape.tags.exists("colliding");
			g.color = isColliding ? Color.White : Color.Red;
			shapeDrawer.drawShape(shape);
		}

		g.color = Color.White;
	}
	#end

	public function update(dt : Float)
	{
		if (!active)
		{
			return;
		}

		syncColliders();
		checkCollisionAgainstScene();

		updateChildren(dt);
	}

	function syncColliders()
	{
		// Modifying properties on a Shape causes its entire transform
		// to be refreshed, so we only want to do this when necessary.
		if (!_isDirty)
		{
			return;
		}

		for (collider in _colliders)
		{
			var shape = collider.shape;
			var offset = shape.data.offset;

			shape.x = globalX + offset.x;
			shape.y = globalY + offset.y;
			shape.scaleX = trueScale.x;
			shape.scaleY = trueScale.y;
			shape.rotation = trueRotation;
		}

		_isDirty = false;
	}

	public function checkCollision(collideables : ReadOnlyArray<ICollideable>,
			?response : (collider : Collider, otherCollider : Collider, result : ShapeCollision) -> Void)
	{
		for (collider in colliders)
		{
			for (collideable in collideables)
			{
				checkCollisionAgainst(collider, collideable, response);
			}
		}
	}

	function checkCollisionAgainstScene()
	{
		if (scene == null)
		{
			return;
		}
		else if (!canCollide)
		{
			return;
		}

		checkCollision(scene.collideables);
	}

	var _didEnter : Bool = false;
	var _didExit : Bool = false;

	function checkCollisionAgainst(collider : Collider, collideable : ICollideable,
			?response : (collider : Collider, otherCollider : Collider, result : ShapeCollision) -> Void)
	{
		if (collideable == this || !collideable.canCollide)
		{
			return;
		}

		var shape = collider.shape;

		_didEnter = false;
		_didExit = false;

		for (otherCollider in collideable.colliders)
		{
			var other = otherCollider.shape;
			var result = shape.test(other);

			if (response == null)
			{
				collisionResponse(collider, otherCollider, result);
			}
			else
			{
				response(collider, otherCollider, result);
			}
		}

		// Propogate down through children
		if (Std.is(collideable, Entity))
		{
			var collideableEntity = cast(collideable, Entity);
			for (child in collideableEntity.children)
			{
				checkCollisionAgainst(collider, child, response);
			}
		}
	}

	function collisionResponse(collider : Collider, otherCollider : Collider, result : ShapeCollision)
	{
		var hasCollision = result != null;
		var collidingWith = collider._collidingWith;
		var alreadyColliding = collidingWith.indexOf(otherCollider) > -1;

		if (hasCollision)
		{
			var shape = collider.shape;
			var otherShape = otherCollider.shape;

			var isTrigger = shape.tags.exists("trigger");
			var isOtherTrigger = otherShape.tags.exists("trigger");

			if (!immobile && !isTrigger && !isOtherTrigger)
			{
				separate(result);
			}

			if (!alreadyColliding && !_didEnter)
			{
				collidingWith.push(otherCollider);

				onCollisionEnter.dispatch(collider, otherCollider, result);
				_didEnter = true;
			}
		}
		else
		{
			if (alreadyColliding && !_didExit)
			{
				collidingWith.remove(otherCollider);

				onCollisionExit.dispatch(collider, otherCollider);
				_didExit = true;
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

	function childSort(a : Entity, b : Entity) : Int
	{
		return a.priority - b.priority;
	}

	public function addChild(child : Entity) : Entity
	{
		child.parent = this;

		children.push(child);
		children.sort(childSort);

		onChildAdded.dispatch(child);

		return child;
	}

	public function removeChild(child : Entity) : Entity
	{
		child.parent = null;

		children.remove(child);
		children.sort(childSort);

		onChildRemoved.dispatch(child);

		return child;
	}

	public function clear()
	{
		var child = children.pop();
		while (child != null)
		{
			onChildRemoved.dispatch(child);
			child = children.pop();
		}
	}

	public function filter(predicate : (child : Entity) -> Bool, recurse : Bool = false) : ReadOnlyArray<Entity>
	{
		var filtered : Array<Entity> = new Array<Entity>();

		if (recurse)
		{
			for (child in children)
			{
				filtered = filtered.concat(filterHelper(predicate, child));
			}
		}
		else
		{
			filtered = children.filter(predicate);
		}

		return filtered;
	}

	function filterHelper(predicate : (child : Entity) -> Bool, entity : Entity) : Array<Entity>
	{
		var filtered : Array<Entity> = new Array<Entity>();

		if (predicate(entity))
		{
			filtered.push(entity);
		}

		for (child in entity.children)
		{
			filtered = filtered.concat(filterHelper(predicate, child));
		}

		return filtered;
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

	public function onAddedToParent(newParent : Entity) {}

	public function onRemovedFromParent(oldParent : Entity) {}

	public function addCollider(shape : Shape) : Shape
	{
		shape.data = {
			offset: {
				x: shape.x,
				y: shape.y
			}
		};

		shape.x += globalX;
		shape.y += globalY;

		var collider = new Collider(this, shape);
		_colliders.push(collider);

		return shape;
	}

	public function addTrigger(trigger : Shape) : Shape
	{
		trigger.tags.set("trigger", "trigger");

		return addCollider(trigger);
	}

	public function interact() {}

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
		_isDirty = true;

		return position.x = value;
	}

	function get_y() : Float
	{
		return position.y;
	}

	function set_y(value : Float) : Float
	{
		_isDirty = true;

		return position.y = value;
	}

	function get_globalPosition() : FastVector2
	{
		if (parent == null)
		{
			return position;
		}

		return new FastVector2(parent.x + x, parent.y + y);
	}

	function get_globalX() : Float
	{
		if (parent == null)
		{
			return x;
		}

		return parent.globalX + x;
	}

	function get_globalY() : Float
	{
		if (parent == null)
		{
			return y;
		}

		return parent.globalY + y;
	}

	function set_rotation(value : Float) : Float
	{
		_isDirty = true;

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

	function set_scale(value : FastVector2) : FastVector2
	{
		_isDirty = true;

		return scale = value;
	}

	function get_scaleX() : FastFloat
	{
		return scale.x;
	}

	function set_scaleX(x : FastFloat) : FastFloat
	{
		_isDirty = true;

		return scale.x = x;
	}

	function get_scaleY() : FastFloat
	{
		return scale.y;
	}

	function set_scaleY(y : FastFloat) : FastFloat
	{
		_isDirty = true;

		return scale.y = y;
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

	function get_colliders() : ReadOnlyArray<Collider>
	{
		return _colliders;
	}

	function set_immobile(value : Bool) : Bool
	{
		for (child in children)
		{
			child.immobile = value;
		}

		return immobile = value;
	}

	function set_canCollide(value : Bool) : Bool
	{
		for (child in children)
		{
			child.canCollide = value;
		}

		return canCollide = value;
	}

	function set_parent(value : Entity) : Entity
	{
		if (parent != null)
		{
			onRemovedFromParent(parent);
		}

		if (value != null)
		{
			onAddedToParent(parent);
		}

		return parent = value;
	}
}
