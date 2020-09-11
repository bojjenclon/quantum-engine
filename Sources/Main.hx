package;

import kha.System;
import quantum.QuantumEngine;

class Main
{
	public static function main()
	{
		var engine = QuantumEngine.engine;
		System.start({title: "Quantum Engine", width: 640, height: 360}, function(_)
		{
			engine.initialize(640, 360);
		});
	}
}
