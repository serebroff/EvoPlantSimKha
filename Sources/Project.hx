package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Assets;
import LevelData;
//import FPS;

using kha.graphics2.GraphicsExtension;

class Project {
    public var previousRealTime:Float;
    public var realTime:Float;
	public var tickperframe:Float;

	public static var ecosystem:Ecosystem;
	public static var fps:FPS;

	var font: kha.Font;
	var allLoaded : Bool;

	
	public function new() {
	
		allLoaded = false;
        previousRealTime = 0.0;
        realTime         = 0.0;

		Assets.loadEverything(loadAll);



		System.notifyOnRender(render);

		fps = new FPS();
		
		//Scheduler.addTimeTask(update, 0, 1 / 60);
	

		kha.input.Mouse.get().notify(onMouseDown, null, onMouseMove, null);

	}

	function loadAll()
	{
	    font             = Assets.fonts.arial_black;
	    initLevel();
		
		allLoaded =true;
	}
	
	function initLevel()
	{

		Ecosystem.instance;
	}
	
	function onMouseMove(x,y, ox, oy)
	{
	}
	
	function onMouseDown(x,y,_)
	{
	}

	function update(): Void {
	}


	function render(framebuffer: Framebuffer): Void {
		
		if (!allLoaded) return;

        previousRealTime = realTime;
        realTime = Scheduler.time();
		tickperframe = (realTime - previousRealTime) * 1000;

		Ecosystem.instance.Calculate(tickperframe);


		var g2 = framebuffer.g2;
		g2.begin(true, kha.Color.Cyan);
		

       //var fps = 1.0 / ( realTime - previousRealTime );
	   fps.update();

        g2.font = font;
        g2.fontSize = 32;
        g2.color = kha.Color.Black;
		g2.drawString( "FPS " + Std.string(fps.getFPS()), 20, 20);

		g2.drawString( "NUM " + Std.string(Ecosystem.instance.creatures.length), 20, 40);
		Ecosystem.instance.Render(framebuffer);
		
		g2.end();		
	}
}
