package quantum.partials;

import differ.data.ShapeCollision;
import differ.shapes.Shape;
import haxe.ds.ReadOnlyArray;
import signals.Signal2;
import signals.Signal3;
import quantum.entities.Collider;
import quantum.ds.UniqueArray;

interface ICollideable
{
	public final onCollisionEnter : Signal3<Collider, Collider, ShapeCollision>;
	public final onCollisionExit : Signal2<Collider, Collider>;

	public var priority : Int;
	public final tags : UniqueArray<String>;

	public var colliders(get, never) : ReadOnlyArray<Collider>;
	public var immobile(default, set) : Bool;
	public var canCollide(default, set) : Bool;
}
