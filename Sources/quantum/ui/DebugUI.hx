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
	public static var FONT : String = '_8_bit_hud';

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
				drawUIPanel();
			}

			if (ui.panel(Id.handle({selected: true}), "Drawing"))
			{
				drawDrawingPanel();
			}
		}

		if (_showStatsWindow)
		{
			_statsWindow.redraws = 1;
			if (ui.window(_statsWindow, statsWinX, statsWinY, statsWinWidth, statsWinHeight))
			{
				if (ui.panel(Id.handle({selected: true}), "Stats"))
				{
					drawStatsPanel();
				}
			}
		}
	}

	function drawUIPanel()
	{
		_showStatsWindow = ui.check(_showStatsCheck, "Show Stats");
	}

	function drawDrawingPanel()
	{
		var debugDrawValue = ui.check(_debugDrawCheck, "Debug Draw");
		if (_debugDrawCheck.changed)
		{
			onDebugDrawCheckChanged.dispatch(debugDrawValue);
		}
	}

	function drawStatsPanel()
	{
		var engine = QuantumEngine.engine;

		// Delta Time Section
		ui.row([0.5, 0.5]);

		ui.text("DT:");

		var deltaTimeString = '${engine.timer.deltaTime}'.substring(0, 6);
		ui.text(deltaTimeString, Align.Right);

		ui.separator(2);

		drawDeltaTimeGraph(30);

		// FPS Section
		ui.row([0.5, 0.5]);

		ui.text("FPS:");

		var fpsString = '${engine.timer.fpsAvg}'.substring(0, 5);
		ui.text(fpsString, Align.Right);

		ui.separator(2);

		drawFPSGraph(30);
	}

	function drawDeltaTimeGraph(dataPoints : Int = 25, barSpace : Int = 2)
	{
		var engine = QuantumEngine.engine;

		var deltaTimeList = engine.timer._deltaTimeList;
		deltaTimeList = deltaTimeList.slice(deltaTimeList.length - dataPoints);
		var deltaTimeBars = deltaTimeList.length;

		var deltaTimeGraphWidth = 170;
		var deltaTimeBarWidth = Math.max(1, Math.floor((deltaTimeGraphWidth - (barSpace * deltaTimeBars)) / deltaTimeBars));

		var deltaTimeMax = Math.NEGATIVE_INFINITY;
		var deltaTimeMin = Math.POSITIVE_INFINITY;

		for (fps in deltaTimeList)
		{
			if (fps > deltaTimeMax)
			{
				deltaTimeMax = fps;
			}

			if (fps < deltaTimeMin)
			{
				deltaTimeMin = fps;
			}
		}

		var xOffset = ((deltaTimeGraphWidth - ((deltaTimeBarWidth + barSpace) * deltaTimeBars))) / 2;
		var barX = 5 + xOffset;
		var barY = 5;
		var barHeight = 30;

		for (deltaTime in deltaTimeList)
		{
			var deltaTimeHeight = barHeight * deltaTime / deltaTimeMax;
			ui.fill(barX, barY + (barHeight - deltaTimeHeight), deltaTimeBarWidth, deltaTimeHeight, Color.Cyan);
			barX += Math.ceil(deltaTimeBarWidth + barSpace);
		}

		ui.separator(40, false);
	}

	function drawFPSGraph(dataPoints : Int = 25, barSpace : Int = 2)
	{
		var engine = QuantumEngine.engine;

		var fpsList = engine.timer._fpsList;
		fpsList = fpsList.slice(fpsList.length - dataPoints);
		var fpsBars = fpsList.length;

		var fpsGraphWidth = 170;
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
