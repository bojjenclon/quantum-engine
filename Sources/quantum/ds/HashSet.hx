package quantum.ds;

import quantum.ds.IHashable;
import haxe.ds.StringMap;

/**
 * Simple HashSet implemenation. Uses object supplied hashing to generate a StringMap and checks said map for unique hashes before adding new values.
 */
class HashSet<V:IHashable>
{
	var _map : StringMap<V>;

	public function new()
	{
		_map = new StringMap<V>();
	}

	function add(value : V)
	{
		var hash = value.hash();
		if (_map.exists(hash))
		{
			return false;
		}

		_map.set(hash, value);

		return true;
	}

	function remove(value : V)
	{
		_map.remove(value.hash());
	}

	function has(value : V)
	{
		return _map.exists(value.hash());
	}
}
