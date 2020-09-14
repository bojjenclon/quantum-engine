package quantum;

import quantum.ui.DebugUI;
import kha.Scheduler;

@:allow(quantum.ui.DebugUI)
class Timer
{
	static inline final FPS_LIST_MAX : Int = 100;
	static inline final DELTA_TIME_LIST_MAX : Int = 100;

	public var deltaTime(default, null) : Float;
	public var fps(default, null) : Float;
	public var fpsAvg(get, never) : Float;

	var _lastTime : Float;

	var _fpsIndex : Int = 0;
	var _fpsSum : Float = 0;
	var _fpsList : Array<Float> = [];

	var _deltaTimeIndex : Int = 0;
	var _deltaTimeList : Array<Float> = [];

	public function new()
	{
		reset();
	}

	public function update() : Float
	{
		var currentTime = Scheduler.time();
		deltaTime = currentTime - _lastTime;
		_lastTime = currentTime;

		var fpsNew = 1 / deltaTime;
		if (Math.isFinite(fpsNew))
		{
			fps = fpsNew;

			_fpsSum -= _fpsList[_fpsIndex];
			_fpsSum += fps;
			_fpsList[_fpsIndex] = fps;
			_fpsIndex++;
			if (_fpsIndex == FPS_LIST_MAX)
			{
				_fpsIndex = 0;
			}
		}

		_deltaTimeList[_deltaTimeIndex++] = deltaTime;
		if (_deltaTimeIndex == DELTA_TIME_LIST_MAX)
		{
			_deltaTimeIndex = 0;
		}

		return deltaTime;
	}

	public function reset()
	{
		_lastTime = Scheduler.time();
		deltaTime = 0;

		_fpsList = [];
		for (_ in 0...FPS_LIST_MAX)
		{
			_fpsList.push(0);
		}
	}

	function get_fpsAvg() : Float
	{
		return _fpsSum / FPS_LIST_MAX;
	}
}
