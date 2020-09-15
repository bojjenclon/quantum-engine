package quantum;

import kha.input.Mouse;
import kha.input.Keyboard;
import kha.input.KeyCode;
import quantum.ds.UniqueArray;
import haxe.ds.StringMap;

// Based on https://github.com/Nazariglez/Gecko2D/blob/master/Sources/gecko/input/Keyboard.hx
class Input
{
	public static final instance : Input = new Input();

	public var mouseX(default, null) : Int = 0;
	public var mouseY(default, null) : Int = 0;

	var _keyMappings : StringMap<UniqueArray<KeyCode>> = new StringMap<UniqueArray<KeyCode>>();
	var _mouseMappings : StringMap<UniqueArray<Int>> = new StringMap<UniqueArray<Int>>();

	var _pressedKeys : Map<KeyCode, Bool> = new Map<KeyCode, Bool>();
	var _releasedKeys : Map<KeyCode, Bool> = new Map<KeyCode, Bool>();
	var _downKeys : Map<KeyCode, Float> = new Map<KeyCode, Float>();

	var _pressedMouse : Map<Int, Bool> = new Map<Int, Bool>();
	var _releasedMouse : Map<Int, Bool> = new Map<Int, Bool>();
	var _downMouse : Map<Int, Float> = new Map<Int, Float>();

	private function new() {}

	public function initialize()
	{
		var keyboard = Keyboard.get();
		keyboard.notify(onKeyDown, onKeyUp);

		var mouse = Mouse.get();
		mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
	}

	public function update(dt : Float)
	{
		// Key Management
		_pressedKeys.clear();

		for (key in _downKeys.keys())
		{
			_downKeys[key] += dt;
		}

		_releasedKeys.clear();

		// Mouse Management
		_pressedMouse.clear();

		for (button in _downMouse.keys())
		{
			_downMouse[button] += dt;
		}

		_releasedMouse.clear();
	}

	public function registerKey(name : String, key : KeyCode)
	{
		if (!_keyMappings.exists(name))
		{
			_keyMappings.set(name, new UniqueArray<KeyCode>());
		}

		var map = _keyMappings.get(name);
		map.add(key);
	}

	public function unregisterKey(name : String, key : KeyCode)
	{
		if (!_keyMappings.exists(name))
		{
			return;
		}

		var map = _keyMappings.get(name);
		map.remove(key);
	}

	public function registerMouseButton(name : String, button : Int)
	{
		if (!_mouseMappings.exists(name))
		{
			_keyMappings.set(name, new UniqueArray<KeyCode>());
		}

		var map = _mouseMappings.get(name);
		map.add(button);
	}

	public function unregisterMouseButton(name : String, button : Int)
	{
		if (!_mouseMappings.exists(name))
		{
			return;
		}

		var map = _mouseMappings.get(name);
		map.remove(button);
	}

	public function isDown(name : String, duration : Float = -1) : Bool
	{
		var hasKeyMap = _keyMappings.exists(name);
		var hasMouseMap = _mouseMappings.exists(name);

		if (!hasKeyMap && !hasMouseMap)
		{
			return false;
		}

		if (hasKeyMap)
		{
			var keyMap = _keyMappings.get(name);
			for (code in keyMap)
			{
				var isKeyDown = _downKeys.exists(code);
				var downLongEnough = isKeyDown && (duration == -1 || _downKeys[code] > duration);

				if (downLongEnough)
				{
					return true;
				}
			}
		}

		if (hasMouseMap)
		{
			var mouseMap = _mouseMappings.get(name);
			for (button in mouseMap)
			{
				var isButtonDown = _downMouse.exists(button);
				var downLongEnough = isButtonDown && (duration == -1 || _downMouse[button] > duration);

				if (downLongEnough)
				{
					return true;
				}
			}
		}

		return false;
	}

	public function justPressed(name : String)
	{
		var hasKeyMap = _keyMappings.exists(name);
		var hasMouseMap = _mouseMappings.exists(name);

		if (!hasKeyMap && !hasMouseMap)
		{
			return false;
		}

		if (hasKeyMap)
		{
			var keyMap = _keyMappings.get(name);
			for (code in keyMap)
			{
				if (_pressedKeys.exists(code))
				{
					return true;
				}
			}
		}

		if (hasMouseMap)
		{
			var mouseMap = _mouseMappings.get(name);
			for (button in mouseMap)
			{
				if (_pressedMouse.exists(button))
				{
					return true;
				}
			}
		}

		return false;
	}

	public function justReleased(name : String)
	{
		var hasKeyMap = _keyMappings.exists(name);
		var hasMouseMap = _mouseMappings.exists(name);

		if (!hasKeyMap && !hasMouseMap)
		{
			return false;
		}

		if (hasKeyMap)
		{
			var keyMap = _keyMappings.get(name);
			for (code in keyMap)
			{
				if (_releasedKeys.exists(code))
				{
					return true;
				}
			}
		}

		if (hasMouseMap)
		{
			var mouseMap = _mouseMappings.get(name);
			for (button in mouseMap)
			{
				if (_releasedMouse.exists(button))
				{
					return true;
				}
			}
		}

		return false;
	}

	public function downDuration(name : String) : Float
	{
		var hasKeyMap = _keyMappings.exists(name);
		var hasMouseMap = _mouseMappings.exists(name);

		if (!hasKeyMap && !hasMouseMap)
		{
			return -1;
		}

		if (hasKeyMap)
		{
			var keyMap = _keyMappings.get(name);
			for (code in keyMap)
			{
				if (_downKeys.exists(code))
				{
					return _downKeys[code];
				}
			}
		}

		if (hasMouseMap)
		{
			var mouseMap = _mouseMappings.get(name);
			for (button in mouseMap)
			{
				if (_downMouse.exists(button))
				{
					return _downMouse[button];
				}
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

	function onMouseDown(button : Int, x : Int, y : Int)
	{
		mouseX = x;
		mouseY = y;

		_pressedMouse.set(button, true);
		_downMouse.set(button, 0);
	}

	function onMouseUp(button : Int, x : Int, y : Int)
	{
		mouseX = x;
		mouseY = y;

		_pressedMouse.remove(button);
		_downMouse.remove(button);
		_releasedMouse.set(button, true);
	}

	function onMouseMove(x : Int, y : Int, moveX : Int, moveY : Int)
	{
		mouseX = x;
		mouseY = y;
	}

	function onMouseWheel(delta : Float) {}
}
