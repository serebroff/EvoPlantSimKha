package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Project;
using Plant;
using Leaf;

class IntersectionWithLeaf {
	public var pos:Vec2;
	public var distance:Float;
	public var leaf:Leaf;
	public var power:Float;
	public var enegryToAdd:Float;

	public function new(p:Vec2, d:Float, l:Leaf, e:Float) {
		pos = p;
		distance = d;
		leaf = l;
		power = 1;
		enegryToAdd = e;
	}

	public function set(p:Vec2, d:Float, l:Leaf, e:Float) {
		pos.setFrom(p);
		distance = d;
		leaf = l;
		power = 1;
		enegryToAdd = e;
	}
}

//------------------------------------- ------------------
// Beam class
//-------------------------------------------------------
class Beam {
	public var pos1:Vec2;
	public var pos2:Vec2;
	public var intercections_with_leaf:Array<IntersectionWithLeaf>;
	public var numintersections:Int;
	public var dist:Float;

	var v1:Vec2;
	var v2:Vec2;
	var v3:Vec2;

	public function new() {
		pos1 = new Vec2();
		pos2 = new Vec2();
		v1 = new Vec2();
		v2 = new Vec2();
		v3 = new Vec2();
		dist = 100000;
		numintersections = 0;
		intercections_with_leaf = [];
	}

	public function Init() {
		numintersections = 0;
	}

	public function GetRayToLineSegmentIntersection(rayOrigin:Vec2, rayDirection:Vec2, point1:Vec2, point2:Vec2):Float {
		v2.setFrom(point2.sub(point1));
		v3.set(-rayDirection.y, rayDirection.x);

		var dot:Float = v2.dot(v3);
		if (Math.abs(dot) < 0.000001) {
			return 0;
		}

		v1.setFrom(rayOrigin.sub(point1));

		var t1:Float = v2.crossProduct(v1) / dot;
		var t2:Float = v1.dot(v3) / dot;

		if (t1 >= 0.0 && (t2 >= 0.0 && t2 <= 1.0)) {
			return t1;
		}

		return 0;
	}

	public function CheckCollisionWithLeaf(leaf:Leaf) {
		var distance:Float = 0;
		var distance2:Float = 0;
		var delta:Float = 0;

		distance = GetRayToLineSegmentIntersection(pos1, Sunlight.dir, leaf.v2, leaf.v3);
		if (distance == 0) {
			distance = GetRayToLineSegmentIntersection(pos1, Sunlight.dir, leaf.v2, leaf.v4);
			if (distance != 0) {
				distance2 = GetRayToLineSegmentIntersection(pos1, Sunlight.dir, leaf.v3, leaf.v4);
			}
		} else {
			distance2 = GetRayToLineSegmentIntersection(pos1, Sunlight.dir, leaf.v2, leaf.v4);
			if (distance2 == 0) {
				distance2 = GetRayToLineSegmentIntersection(pos1, Sunlight.dir, leaf.v3, leaf.v4);
			}
		}

		if (distance != 0) {
			if (numintersections == intercections_with_leaf.length) {
				intercections_with_leaf.push(new IntersectionWithLeaf(pos1.add(Sunlight.dir.mult(distance)), distance, leaf, Math.abs(distance - distance2)));
				numintersections++;
			} else {
				intercections_with_leaf[numintersections].set(pos1.add(Sunlight.dir.mult(distance)), distance, leaf, Math.abs(distance - distance2));
				numintersections++;
			}
		}
	}

	public function AddEnergyToHitedLeaves() {
		if (numintersections == 0) {
			return;
		}

		/*		intercections_with_leaf.sort(function(a, b) {
			return Math.ceil(a.distance - b.distance);
		});*/

		var i:IntersectionWithLeaf;
		var n:Int = 1;
		var m:Int = 0;

		// sort intersections by distance
		while (n < numintersections) {
			m = n - 1;
			while (m >= 0 && (intercections_with_leaf[m + 1].distance < intercections_with_leaf[m].distance)) {
				i = intercections_with_leaf[m + 1];
				intercections_with_leaf[m + 1] = intercections_with_leaf[m];
				intercections_with_leaf[m] = i;
				m--;
			}
			n++;
		}

		var power:Float = 1;
		var k:Float = 1;

		n = 0;

		while (n < numintersections) {
			i = intercections_with_leaf[n++];

			k = power * i.enegryToAdd / Sunlight.LOSS_OF_EVERGY_IN_LEAF_WIDTH;
			if (k > 1) {
				k = 1;
			}
			i.leaf.AddEnergy(k * Sunlight.BEAM_ENERGY * FPS.dt);
			power -= k;
			if (power < 0) {
				power = 0;
			}
			i.power = power;
		}
	}

	public function Draw(framebuffer:Framebuffer):Void {
		var g2 = framebuffer.g2;
		var r:Float = 1 - 0.1 * Math.abs(Sunlight.sun_angle);
		var alpha:Float = 0.5;
		var alpha0:Float = 0.0;

		g2.color = kha.Color.fromFloats(1, r, 0, alpha0 + alpha);

		if (numintersections != 0) {
			var i:Int = 0;
			g2.drawLine(pos1.x, pos1.y, intercections_with_leaf[i].pos.x, intercections_with_leaf[i].pos.y, 2);
			while (i < numintersections - 1) {
				g2.color = kha.Color.fromFloats(1, r, 0, alpha0 + alpha * intercections_with_leaf[i].power);
				g2.drawLine(intercections_with_leaf[i].pos.x, intercections_with_leaf[i].pos.y, intercections_with_leaf[i + 1].pos.x,
					intercections_with_leaf[i + 1].pos.y, 2);
				i++;
			}

			g2.color = kha.Color.fromFloats(1, r, 0, alpha0 + alpha * intercections_with_leaf[i].power);
			g2.drawLine(intercections_with_leaf[i].pos.x, intercections_with_leaf[i].pos.y, pos2.x, pos2.y, 2);
		} else {
			g2.drawLine(pos1.x, pos1.y, pos2.x, pos2.y, 2);
		}
	}
}
