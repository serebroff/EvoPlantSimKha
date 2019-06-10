package;

import kha.Framebuffer;
import kha.System;
import haxe.ds.Vector;

using Utils;
using kha.graphics2.GraphicsExtension;
using Plant;
using Leaf;
using Beam;

//------------------------------------- ------------------
// Sunlight class
//-------------------------------------------------------
class Sunlight {
	// constants
	public static inline var BEAM_ENERGY = 300;
	public static inline var LOSS_OF_EVERGY_IN_LEAF_WIDTH = 30;
	public static inline var NUM_BEAMS = 140;
	public static var BEAM_DISTANCE = 15;
	public static inline var RADIUS = 1700;
	public static inline var SUN_FULL_TURN_IN_SEC = 20;
	public static var BEAM_LENGTH = 2700;
	public static var dir:Vec2;

	public var pos:Vec2;
	public var perpendicular:Vec2;
	public var ar_beams:Array<Beam>;
	//    public var ar_beams: Vector<Beam>;
	public var center:Vec2;
	public var angle:Float;
	public var radius:Float;
	public var beam_delta:Float;

	public static var sun_time:Float;
	public static var sun_angle:Float;

	public var Frequency:Float; // per sec per pixel

	public function new() {
		dir = new Vec2(2, 1);
		pos = new Vec2();
		perpendicular = new Vec2();
		Frequency = 1;
		angle = 0;
		radius = RADIUS;
		beam_delta = 0;

		sun_time = 0;
		sun_angle = 0;

		ar_beams = [for (i in 0...NUM_BEAMS) new Beam()];
		//      ar_beams = new Vector<Beam>(NUM_BEAMS);
		/*for (b in ar_beams)
			{
				b.Init();
		}*/

		center = new Vec2(0, 0);
	}

	public function Calculate(dt:Float) {
		sun_time += dt;
		sun_angle = Math.sin(Math.PI * sun_time / SUN_FULL_TURN_IN_SEC);

		angle = -Math.PI * 0.5 - Math.PI * 0.2 * sun_angle;
		dir.set(-Math.cos(angle), -Math.sin(angle));

		pos.setFrom(center.add(dir.mult(-radius)));

		perpendicular.set(dir.y, -dir.x);
		var v:Vec2;
		var i:Int = 0;

		while (i < NUM_BEAMS) {
			ar_beams[i].Init();

			v = ar_beams[i].pos1;
			v.setFrom(pos.add(perpendicular.mult(beam_delta + BEAM_DISTANCE * (i - Math.floor(NUM_BEAMS / 2)))));
			ar_beams[i].pos2.setFrom(v.add(dir.mult(BEAM_LENGTH)));
			ar_beams[i].dist = BEAM_LENGTH;

//			ar_beams[i].numintersections = 0;
//			ar_beams[i].intercections_with_leaf = [];

			i++;
		}
	}

	public function CheckCollisionWithLeaf(leaf:Leaf) {
		var index0:Int = Math.ceil(perpendicular.dot(leaf.startPos) / BEAM_DISTANCE) + Math.floor(NUM_BEAMS / 2);
		var index1:Int = Math.ceil(perpendicular.dot(leaf.endPos) / BEAM_DISTANCE) + Math.floor(NUM_BEAMS / 2);
		var i:Int;
		if (index0 > index1) {
			i = index0;
			index0 = index1;
			index1 = i;
		}
		var index_delta:Int = Math.ceil(leaf.widthEnd / BEAM_DISTANCE);
		index0 -= index_delta;
		index1 += index_delta;

		if (index0 < 0) {
			index0 = 0;
		}
		if (index1 >= NUM_BEAMS) {
			index1 = NUM_BEAMS-1;
		}

		i = index0;
		while (i <= index1) {
			ar_beams[i].CheckCollisionWithLeaf(leaf);
			i++;
		}
	}

	public function AddEnergyToHitedLeaves() {
		for (b in ar_beams) {
			b.AddEnergyToHitedLeaves();
		}
	}

	public function Draw(framebuffer:Framebuffer):Void {
		for (b in ar_beams) {
			b.Draw(framebuffer);
		}
	}
}
