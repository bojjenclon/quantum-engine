package;

import kha.System;
import quantum.QuantumEngine;

class Main
{
	public static function main()
	{
		var engine = QuantumEngine.engine;
		System.start({title: "Quantum Engine", width: 1600, height: 900}, function(_)
		{
			engine.initialize(640, 360);
		});
	}
}
