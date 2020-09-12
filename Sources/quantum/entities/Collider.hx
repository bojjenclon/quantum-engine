package quantum.entities;

import differ.shapes.Shape;
import haxe.ds.ReadOnlyArray;

class Collider
{
  public var owner(default, null) : Entity;
  public var shape(default, null) : Shape;

  public var collidingWith(get, never) : ReadOnlyArray<Collider>;
  @:allow(quantum.entities.Entity)
  var _collidingWith : Array<Collider> = [];

	public function new(owner : Entity, shape : Shape)
  {
    this.owner = owner;
    this.shape = shape;
  }

  function get_collidingWith() : ReadOnlyArray<Collider>
  {
    return _collidingWith;
  }
}
