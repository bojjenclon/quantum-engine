package quantum;

import kha.Scheduler;

class Timer
{
	public var deltaTime(default, null) : Float;
	public var lastTime(default, null) : Float;

	public function new()
	{
		reset();
	}

	public function update() : Float
	{
		var currentTime = Scheduler.time();
		deltaTime = currentTime - lastTime;
		lastTime = currentTime;

		return deltaTime;
	}

	public function reset()
	{
		lastTime = Scheduler.time();
		deltaTime = 0;
	}
}
