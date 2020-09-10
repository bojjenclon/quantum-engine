package quantum;

import kha.input.Keyboard;
import kha.input.KeyCode;
import quantum.ds.UniqueArray;
import haxe.ds.StringMap;

enum KeyState
{
	Up;
	Down;
}

class Input
{
	public static final instance : Input = new Input();

	var _mappings : StringMap<UniqueArray<KeyCode>> = new StringMap<UniqueArray<KeyCode>>();

	var _keyState : Map<KeyCode, KeyState> = new Map<KeyCode, KeyState>();
	var _previousKeyState : Map<KeyCode, KeyState> = new Map<KeyCode, KeyState>();

	private function new() {}

	public function initialize()
	{
		var keyboard = Keyboard.get();
		keyboard.notify(onKeyDown, onKeyUp);
	}

	public function update()
	{
		_previousKeyState = _keyState.copy();
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

	public function isDown(name : String) : Bool
	{
		if (!_mappings.exists(name))
		{
			return false;
		}

		var map = _mappings.get(name);
		for (code in map)
		{
			if (_keyState[code] == KeyState.Down)
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
			if (_keyState[code] == KeyState.Up && _previousKeyState[code] == KeyState.Down)
			{
				return true;
			}
		}

		return false;
	}

	public function isUp(name : String) : Bool
	{
		if (!_mappings.exists(name))
		{
			return false;
		}

		var map = _mappings.get(name);
		for (code in map)
		{
			if (_keyState[code] == KeyState.Up)
			{
				return true;
			}
		}

		return false;
	}

	function onKeyDown(code : KeyCode)
	{
		_previousKeyState[code] = _keyState[code];
		_keyState[code] = KeyState.Down;
	}

	function onKeyUp(code : KeyCode)
	{
		_previousKeyState[code] = _keyState[code];
		_keyState[code] = KeyState.Up;
	}
}
