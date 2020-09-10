package;

import kha.System;
import quantum.QuantumEngine;

class Main
{
	public static function main()
	{
		var engine = QuantumEngine.engine;
		System.start({title: "Kha", width: 800, height: 600}, function(_)
		{
			engine.initialize();
		});
	}
}
