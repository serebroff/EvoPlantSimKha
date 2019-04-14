package;

import kha.System;

class Main {
	public static function main() {
		System.init({title: "EvoPlant", width: 1524, height: 900}, function () {
//		System.init({title: "Project",  windowMode: BorderlessWindow}, function () {

			new Project();
		});
	}
}
