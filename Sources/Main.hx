package;

import kha.System;
import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

using Project;

class Main {


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
