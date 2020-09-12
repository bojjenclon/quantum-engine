package quantum.partials;

import quantum.ds.UniqueArray;
import signals.Signal1;
import differ.data.ShapeCollision;
import signals.Signal2;
import differ.shapes.Shape;
import haxe.ds.ReadOnlyArray;

interface ICollideable
{
	public final onCollisionEnter : Signal2<ICollideable, ShapeCollision>;
	public final onCollisionExit : Signal1<ICollideable>;

	public final tags : UniqueArray<String>;
	public var colliders(get, never) : ReadOnlyArray<Shape>;
	public var immobile : Bool;
}
