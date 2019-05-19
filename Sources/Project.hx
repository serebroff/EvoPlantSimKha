package;

import kha.math.FastMatrix3;
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

	}


	public function loadAll()
	{

		//Scheduler.addTimeTask(function () { update(); }, 0, 1 / 10);
		System.notifyOnFrames(function (frames) { render(frames); });

	    font             = Assets.fonts.arial_black;
	    initLevel();
		
		fps.Init();	
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
		if (!allLoaded) {
			return;
		}
		var framebuffer: Framebuffer;
		framebuffer = frames[0];

		fps.update();

		Ecosystem.instance.Calculate(FPS.dt); //tickperframe);


		var g2 = framebuffer.g2;
		var r:Float =  0.1 * Math.abs(Sunlight.sun_angle ) ;
		g2.begin(true, kha.Color.fromFloats( 0.5+r, 0.6, 1, 1));
		
		/*var scaleHeight = (System.windowHeight / 1080);
		var m: kha.math.FastMatrix3 = kha.math.FastMatrix3.scale(scaleHeight,scaleHeight);
		//m.multmat(kha.math.FastMatrix3.translation(System.windowWidth() * 0.5 , System.windowHeight()));
	
		g2.transformation.setFrom(m); */

		g2.transformation.setFrom(kha.math.FastMatrix3.translation(System.windowWidth() * 0.5 , System.windowHeight()));

    	Ecosystem.instance.Render(framebuffer);

		g2.transformation.setFrom(kha.math.FastMatrix3.identity());



        g2.font = font;
        g2.fontSize = 32;
        g2.color = kha.Color.Black;
		g2.drawString( "FPS " + Utils.floatToStringPrecision(fps.getFPS(),1), System.windowWidth()-140, 20); 
		//g2.drawString( "FPS " + Std.string(Math.fceil(fps.getFPS()*10)*0.1), System.windowWidth()-140, 20);
		
		g2.fontSize = 24;

        
		g2.drawString( "PLANTS " + Std.string(Ecosystem.numLivePlants) + " / " + Std.string(Ecosystem.plants.length), 20, 20);
		g2.drawString( "BRANCHES " + Std.string(Ecosystem.numLiveBranches) + " / " + Std.string(Ecosystem.branches.length), 20, 40);
		g2.drawString( "LEAVES " + Std.string(Ecosystem.numLiveLeaves) + " / " + Std.string(Ecosystem.leaves.length), 20, 60);
		g2.drawString( "SEEDS " + Std.string(Ecosystem.numLiveSeeds) + " / " + Std.string(Ecosystem.seeds.length), 20, 80);

		g2.fontSize = 64;
		var year: Int = Math.ceil(Ecosystem.ecosystem_time / Sunlight.SUN_FULL_TURN_IN_SEC); 
		
		g2.drawString( "YEAR " + Std.string(year), System.windowWidth()/2-60, 60); 
		
		g2.end();	



	}
}
