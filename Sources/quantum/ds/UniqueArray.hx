package quantum.ds;

import haxe.Unserializer;
import haxe.Serializer;

private class UniqueArrayIterator<V>
{
	var _array : UniqueArray<V>;
	var _idx : Int;

	public function new(array : UniqueArray<V>)
	{
		_array = array;
		_idx = 0;
	}

	public function hasNext() : Bool
	{
		return _idx < _array.length;
	}

	public function next() : V
	{
		return _array.get(_idx++);
	}
}

/**
 * Wraps a basic array. Ensures elements are unique before adding them.
 */
class UniqueArray<V>
{
	var _entries : Array<V>;

	public var length(get, never) : Int;

	public function new()
	{
		_entries = [];
	}

	public inline function add(value : V) : Bool
	{
		if (has(value))
		{
			return false;
		}

		_entries.push(value);

		return true;
	}

	public inline function get(idx : Int) : V
	{
		return _entries[idx];
	}

	public inline function remove(value : V)
	{
		_entries.remove(value);
	}

	public inline function has(value : V)
	{
		return _entries.indexOf(value) > -1;
	}

	public inline function clear() 
	{
		_entries = [];
	}

	public inline function join(sep : String) : String
	{
		return _entries.join(sep);
	}

	public function iterator() : UniqueArrayIterator<V>
	{
		return new UniqueArrayIterator<V>(this);
	}

	@:keep
	function hxSerialize(serializer : Serializer)
	{
		serializer.serialize(_entries);
	}

	@:keep
	function hxUnserialize(unserializer : Unserializer)
	{
		_entries = unserializer.unserialize();
	}

	function get_length() : Int
	{
		return _entries.length;
	}
}
