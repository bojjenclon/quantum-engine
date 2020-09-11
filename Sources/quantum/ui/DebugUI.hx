package quantum.ui;

import kha.Font;
import kha.Color;
import zui.Canvas.TCanvas;
import zui.Zui.Align;
import kha.System;
import signals.Signal1;
import zui.Id;

class DebugUI extends BaseUI
{
	public var onDebugDrawCheckChanged : Signal1<Bool> = new Signal1<Bool>();

	var _optionsWindow = Id.handle();
	var _statsWindow = Id.handle();

	var _debugDrawCheck = Id.handle();
	var _showStatsCheck = Id.handle();

	var _showStatsWindow : Bool = true;

	public function new(font : Font)
	{
		super(font);

		_windows.push(_optionsWindow);
		_windows.push(_statsWindow);

		// Start checked
		_showStatsCheck.selected = true;
	}

	override function generateUI()
	{
		var engine = QuantumEngine.engine;

		var scale = ui.SCALE();

		var screenWidth = System.windowWidth();
		var screenHeight = System.windowHeight();

		var optionsWinWidth = Std.int(200 * scale);
		var optionsWinHeight = Std.int(200 * scale);
		var optionsWinX = 5;
		var optionsWinY = 5;

		var statsWinWidth = Std.int(180 * scale);
		var statsWinHeight = Std.int(200 * scale);
		var statsWinX = screenWidth - statsWinWidth - 5;
		var statsWinY = 5;

		if (ui.window(_optionsWindow, optionsWinX, optionsWinY, optionsWinWidth, optionsWinHeight))
		{
			if (ui.panel(Id.handle({selected: true}), "UI"))
			{
				_showStatsWindow = ui.check(_showStatsCheck, "Show Stats");
			}

			if (ui.panel(Id.handle({selected: true}), "Drawing"))
			{
				var debugDragValue = ui.check(_debugDrawCheck, "Debug Draw");
				if (_debugDrawCheck.changed)
				{
					onDebugDrawCheckChanged.dispatch(debugDragValue);
				}
			}
		}

		if (_showStatsWindow)
		{
			_statsWindow.redraws = 1;
			if (ui.window(_statsWindow, statsWinX, statsWinY, statsWinWidth, statsWinHeight))
			{
				if (ui.panel(Id.handle({selected: true}), "Stats"))
				{
					ui.row([0.5, 0.5]);

					ui.text("FPS:");

					var fpsString = '${engine.timer.fpsAvg}'.substring(0, 5);
					ui.text(fpsString, Align.Right);

					ui.separator(2);

					drawFPSGraph(30);
				}
			}
		}
	}

	function drawFPSGraph(dataPoints : Int = 25, barSpace : Int = 2)
	{
		var engine = QuantumEngine.engine;

		var scale = ui.SCALE();

		var fpsList = engine.timer._fpsList;
		fpsList = fpsList.slice(fpsList.length - dataPoints);
		var fpsBars = fpsList.length;

		var fpsGraphWidth = Std.int(170 * scale);
		var fpsBarWidth = Math.max(1, Math.floor((fpsGraphWidth - (barSpace * fpsBars)) / fpsBars));

		var fpsMax = Math.NEGATIVE_INFINITY;
		var fpsMin = Math.POSITIVE_INFINITY;

		for (fps in fpsList)
		{
			if (fps > fpsMax)
			{
				fpsMax = fps;
			}

			if (fps < fpsMin)
			{
				fpsMin = fps;
			}
		}

		var xOffset = ((fpsGraphWidth - ((fpsBarWidth + barSpace) * fpsBars))) / 2;
		var barX = 5 + xOffset;
		var barY = 5;
		var barHeight = 30;

		for (fps in fpsList)
		{
			var fpsHeight = barHeight * fps / fpsMax;
			ui.fill(barX, barY + (barHeight - fpsHeight), fpsBarWidth, fpsHeight, Color.Green);
			barX += Math.ceil(fpsBarWidth + barSpace);
		}

		ui.separator(40, false);
	}
}
