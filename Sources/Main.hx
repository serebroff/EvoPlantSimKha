package;

import kha.Assets;
import kha.System;
import kha.CompilerDefines;
#if kha_html5
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
#end

using Project;

class Main {
	public static function main() {
		setFullWindowCanvas();
		System.start({title: "EvoPlantSim", width: 1920, height: 1080}, // window: { mode: Fullscreen}},
		function(_) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function() {
				// Avoid passing update/render directly,
				// so replacing them via code injection works
				var project = new Project();
				project.loadAll();
			});
		});
	}

	static function setFullWindowCanvas():Void {
		#if kha_html5
		// make html5 canvas resizable
		document.documentElement.style.padding = "0";
		document.documentElement.style.margin = "0";
		document.body.style.padding = "0";
		document.body.style.margin = "0";
		//document.body.style.width = "50%";
		//document.body.style.height = "50%";
		var canvas:CanvasElement = cast document.getElementById(CompilerDefines.canvas_id);
		canvas.style.display = "block";
	//document.querySelector("meta[name=viewport]").setAttribute('content', 'width=device-width, initial-scale='+(1/window.devicePixelRatio)+', maximum-scale=1.0, user-scalable=0');
		document.getElementById("viewport").setAttribute("content",
                "width=device-width, initial-scale="+ 1/window.devicePixelRatio+", user-scalable=no");

		var resize = function() {
			
//			canvas.style.transform = 'scale(0.666)';
			canvas.width = Std.int(window.innerWidth* window.devicePixelRatio);
			canvas.height = Std.int(window.innerHeight* window.devicePixelRatio);
			canvas.style.width = document.documentElement.clientWidth + "px";
			canvas.style.height = document.documentElement.clientHeight + "px";
			//canvas.style.zoom =  "0.666";
			//document.body.style.zoom =  "0.666";

		}
		window.onresize = resize;
		resize();
		#end
	}
}
 /*
	import kha.System;
	import kha.Window;
	import kha.CompilerDefines;
	#if kha_html5
	import js.html.CanvasElement;
	import js.Browser.document;
	import js.Browser.window;
	#end

	class Main {

	static function main():Void {
		setFullWindowCanvas();

		System.start({title: "New Project", width: 800, height: 600}, init);
	}

	static function init(window:Window):Void {} //Your code

	static function setFullWindowCanvas():Void {
		#if kha_html5
		//make html5 canvas resizable
		document.documentElement.style.padding = "0";
		document.documentElement.style.margin = "0";
		document.body.style.padding = "0";
		document.body.style.margin = "0";
		var canvas:CanvasElement = cast document.getElementById(CompilerDefines.canvas_id);
		canvas.style.display = "block";

		var resize = function() {
			canvas.width = Std.int(window.innerWidth * window.devicePixelRatio);
			canvas.height = Std.int(window.innerHeight * window.devicePixelRatio);
			canvas.style.width = document.documentElement.clientWidth + "px";
			canvas.style.height = document.documentElement.clientHeight + "px";
		}
		window.onresize = resize;
		resize();
		#end
	}

	}
 */
