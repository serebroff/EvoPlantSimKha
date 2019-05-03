package;

import kha.System;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

using Project;

class Main {
	/*static function update(): Void {

	}

	static function render(frames: Array<Framebuffer>): Void {

	}*/

	public static function main() {
		System.start({title: "EvoPlantSim", width:1920, height: 1080 }, //window: { mode: Fullscreen}}, 
		function (_) {
			// Just loading everything is ok for small projects
			Assets.loadEverything(function () {
				// Avoid passing update/render directly,
				// so replacing them via code injection works
				var project = new Project();
				project.loadAll();
			});
		});
	}
}
/*

class Main {
	public static function main() {
		//System.start()
		System.init({title: "EvoPlant", width: 1524, height: 900}, function () {
//		System.init({title: "Project",  windowMode: BorderlessWindow}, function () {

			new Project();
		});
	}
}
*/