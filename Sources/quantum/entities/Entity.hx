package quantum.entities;

import kha.math.Vector2;

class Entity
{
	public var position : Vector2 = new Vector2(0, 0);
	public var x(get, set) : Float;
	public var y(get, set) : Float;

	public var children : Array<Entity> = new Array<Entity>();

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
}
