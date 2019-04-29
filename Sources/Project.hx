package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Assets;


using kha.graphics2.GraphicsExtension;

class Project {
    public var previousRealTime:Float;
    public var realTime:Float;
	static public var tickperframe:Float;

	public static var fps:FPS;

	var font: kha.Font;
	var allLoaded : Bool;

	
	public function new() {
	
		allLoaded = false;
        previousRealTime = 0.0;
        realTime         = 0.0;

		fps = new FPS();

		//Assets.loadEverything(loadAll);

		//loadAll();



		//System.notifyOnRender(render);


		
		//Scheduler.addTimeTask(update, 0, 1 / 60);
	

		//kha.input.Mouse.get().notify(onMouseDown, null, onMouseMove, null);

	}

	public function loadAll()
	{

		//Scheduler.addTimeTask(function () { update(); }, 0, 1 / 10);
		System.notifyOnFrames(function (frames) { render(frames); });

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
		//Ecosystem.instance.Calculate(1/10);
	}

	function render( frames: Array<Framebuffer>)
	{		
		if (!allLoaded) return;
		var framebuffer: Framebuffer;
		framebuffer = frames[0];



		Ecosystem.instance.Calculate(FPS.dt); //tickperframe);


		var g2 = framebuffer.g2;
		var r:Float =  0.1 * Math.abs(Sunlight.sun_angle ) ;
		g2.begin(true, kha.Color.fromFloats( 0.5+r, 0.6, 1, 1));
		

    	Ecosystem.instance.Render(framebuffer);


        g2.font = font;
        g2.fontSize = 32;
        g2.color = kha.Color.Black;
		g2.drawString( "FPS " + Std.string(fps.getFPS()), 20, 20);

		g2.drawString( "BRANCHES " + Std.string(Ecosystem.instance.plants[0].branches.length), 20, 40);
		g2.drawString( "LEAVES " + Std.string(Ecosystem.instance.plants[0].leaves.length), 20, 60);

		
		g2.end();	

		fps.update();	
	}
}
