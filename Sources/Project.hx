package;

import kha.math.FastMatrix3;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Assets;
import kha.input.Mouse;
import kha.input.Surface;

#if kha_html5
import kha.CompilerDefines;
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
#end


using kha.graphics2.GraphicsExtension;
using Utils;

class Project {
    public var previousRealTime:Float;
    public var realTime:Float;
	static public var tickperframe:Float;

	public static var fps:FPS;

	var font: kha.Font;
	var allLoaded : Bool;
	var mouseDown: Bool;
	var touchDown: Bool;
	var touchX: Int;
	var touchY: Int;

	
	public function new() {
	
		allLoaded = false;
		mouseDown = false;
		touchDown = false;
        previousRealTime = 0.0;
        realTime         = 0.0;
		touchX = 0;
		touchY = 0;

		fps = new FPS();

	}


	public function loadAll()
	{

	//	Scheduler.addTimeTask(function () { update(); }, 0, 1 / 40);
		System.notifyOnFrames(function (frames) { render(frames); });
		
		var mouse: Mouse;
		mouse = Mouse.get();
		if (mouse!=null) {
			mouse.notify(onMouseDown, onMouseUp, onMouseMove, onMouseWheel);
		}
		
		var surface: Surface;
		surface = Surface.get();
		if (surface != null) {
			surface.notify( onTouchDown, onTouchUp, onTouchMove );
		}

	    font   = Assets.fonts.arial_black;
	    initLevel();		
		fps.Init();	
		
		Camera.Init();
		allLoaded =true;
	}
	
	function initLevel()
	{

		Ecosystem.instance;
	}
	
	public function onMouseMove(x:Int, y:Int, cx:Int, cy:Int):Void
	{
		if (!touchDown && mouseDown) {
			Camera.translate(cx, cy);
		}
	}
	
	public function onMouseDown(button:Int, x:Int, y:Int):Void 
	{
		mouseDown = true;
	}
	public function onMouseUp(button:Int, x:Int, y:Int):Void {
		mouseDown = false;
	}

	public function onMouseWheel(delta: Int)
	{
		var zoom: Float = 1;
		zoom += 0.05*delta;
		Camera.scale(zoom);
		
	}
	public function onTouchDown( index: Int, x:Int, y:Int):Void 
	{
		touchX = x;
		touchY = y;
		touchDown = true;
	}
	public function onTouchUp( index: Int, x:Int, y:Int):Void {
		touchDown = false;
	}
	public function onTouchMove(touchpad: Int, x:Int, y:Int):Void
	{
		Camera.translate(x - touchX, y - touchY);
		touchX = x; 
		touchY = y;
	}
	
	function update(): Void {
		var dt = FPS.dt;
		FPS.dt = 1/40;
		Ecosystem.instance.Calculate(FPS.dt); 
		FPS.dt = dt;
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
		

		//Camera.identity();
		//Camera.translate(System.windowWidth() * 0.5 , System.windowHeight());
		//

		g2.transformation.setFrom(Matrix3.translation(System.windowWidth() * 0.5 , System.windowHeight()));	
		Camera.load(framebuffer);

    	Ecosystem.instance.Render(framebuffer);

		//g2.drawPolygon()
		//Camera.identity();
		//Camera.load(framebuffer);
		g2.transformation.setFrom(Matrix3.identity());



        g2.font = font;
        g2.fontSize = 32;
        g2.color = kha.Color.Black;
		g2.drawString( "FPS " + Utils.floatToStringPrecision(fps.getFPS(),1), System.windowWidth()-140, 20); 
		g2.drawString( "dt " + Utils.floatToStringPrecision(FPS.dt,4), System.windowWidth()-140, 50); 
 
		
	//	g2.fontSize = 24;

        
		g2.drawString( "plants " + Std.string(Ecosystem.numLivePlants) + " / " + Std.string(Ecosystem.plants.length), 20, 20);
		g2.drawString( "branches " + Std.string(Ecosystem.numLiveBranches) + " / " + Std.string(Ecosystem.branches.length), 20, 50);
		g2.drawString( "leaves " + Std.string(Ecosystem.numLiveLeaves) + " / " + Std.string(Ecosystem.leaves.length), 20, 80);
		g2.drawString( "seeds " + Std.string(Ecosystem.numLiveSeeds) + " / " + Std.string(Ecosystem.seeds.length), 20, 110);

		g2.drawString(  Std.string("zoom: ")  + Utils.floatToStringPrecision(Camera.zoom,2), System.windowWidth()-200, System.windowHeight() - 100); 

		g2.drawString(  Std.string(System.windowWidth()) + " : " +  Std.string(System.windowHeight()), System.windowWidth()-200, System.windowHeight() - 50); 
		
		#if kha_html5
/*		g2.drawString(  "devicePixelRatio " + Std.string(window.devicePixelRatio)  , System.windowWidth()-400, System.windowHeight() - 100); 
		g2.drawString(  "window.innerHeight " + Std.string(window.innerHeight)  , System.windowWidth()-400, System.windowHeight() - 150); 
		g2.drawString(  "clientHeight " + Std.string(document.documentElement.clientHeight)  , System.windowWidth()-400, System.windowHeight() - 200); 
		var canvas:CanvasElement = cast document.getElementById(CompilerDefines.canvas_id);
		g2.drawString(  "canvas.height " + Std.string(canvas.height)  , System.windowWidth()-400, System.windowHeight() - 250); 
	*/	
		#end

		g2.fontSize = 64;
		var year: Int = Math.ceil(Ecosystem.ecosystem_time / Sunlight.SUN_FULL_TURN_IN_SEC); 
		
		g2.drawString( "YEAR " + Std.string(year), System.windowWidth()/2-60, 60); 
		
		g2.end();	


	}
}
