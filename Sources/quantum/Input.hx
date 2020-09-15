package quantum;

import kha.input.Keyboard;
import kha.input.KeyCode;
import quantum.ds.UniqueArray;
import haxe.ds.StringMap;

// Based on https://github.com/Nazariglez/Gecko2D/blob/master/Sources/gecko/input/Keyboard.hx
class Input
{
	public static final instance : Input = new Input();

	var _mappings : StringMap<UniqueArray<KeyCode>> = new StringMap<UniqueArray<KeyCode>>();

	var _pressedKeys : Map<KeyCode, Bool> = new Map<KeyCode, Bool>();
	var _releasedKeys : Map<KeyCode, Bool> = new Map<KeyCode, Bool>();
	var _downKeys : Map<KeyCode, Float> = new Map<KeyCode, Float>();

	private function new() {}

	public function initialize()
	{
		var keyboard = Keyboard.get();
		keyboard.notify(onKeyDown, onKeyUp);
	}

	public function update(dt : Float)
	{
		for (key in _pressedKeys.keys())
		{
			_pressedKeys.remove(key);
		}

		for (key in _downKeys.keys())
		{
			_downKeys[key] += dt;
		}

		for (key in _releasedKeys.keys())
		{
			_releasedKeys.remove(key);
		}
	}

	public function register(name : String, key : KeyCode)
	{
		if (!_mappings.exists(name))
		{
			_mappings.set(name, new UniqueArray<KeyCode>());
		}

		var map = _mappings.get(name);
		map.add(key);
	}

	public function unregister(name : String, key : KeyCode)
	{
		if (!_mappings.exists(name))
		{
			return;
		}

		var map = _mappings.get(name);
		map.remove(key);
	}

	public function isDown(name : String, duration : Float = -1) : Bool
	{
		if (!_mappings.exists(name))
		{
			return false;
		}

		var map = _mappings.get(name);
		for (code in map)
		{
			var isKeyDown = _downKeys.exists(code);
			var downLongEnough = isKeyDown && (duration == -1 || _downKeys[code] > duration);

			if (downLongEnough)
			{
				return true;
			}
		}

		return false;
	}

	public function justPressed(name : String)
	{
		if (!_mappings.exists(name))
		{
			return false;
		}

		var map = _mappings.get(name);
		for (code in map)
		{
			if (_pressedKeys.exists(code))
			{
				return true;
			}
		}

		return false;
	}

	public function justReleased(name : String)
	{
		if (!_mappings.exists(name))
		{
			return false;
		}

		var map = _mappings.get(name);
		for (code in map)
		{
			if (_releasedKeys.exists(code))
			{
				return true;
			}
		}

		return false;
	}

	public function downDuration(name : String) : Float
	{
		var map = _mappings.get(name);
		for (code in map)
		{
			if (_downKeys.exists(code))
			{
				return _downKeys[code];
			}
		}

		return -1;
	}

	function onKeyDown(code : KeyCode)
	{
		_pressedKeys.set(code, true);
		_downKeys.set(code, 0);
	}

	function onKeyUp(code : KeyCode)
	{
		_pressedKeys.remove(code);
		_downKeys.remove(code);
		_releasedKeys.set(code, true);
	}
}
