package;

import kha.System;

class Main {
	public static function main() {
		System.init({title: "Project", width: 1524, height: 1000}, function () {
//		System.init({title: "Project",  windowMode: BorderlessWindow}, function () {

			new Project();
		});
	}
}
