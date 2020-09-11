package quantum.partials;

import differ.data.ShapeCollision;
import signals.Signal2;
import differ.shapes.Shape;
import haxe.ds.ReadOnlyArray;

interface ICollideable
{
	public final onCollision : Signal2<ICollideable, ShapeCollision>;

	public var colliders(get, never) : ReadOnlyArray<Shape>;
	public var immobile : Bool;
}
