
//-------------------------------------------------------
// class of Leaf
//-------------------------------------------------------
//package;
import DNA.OrganID;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Plant;

class Leaf {
	public static inline var LEAF_DEATH_TIME = 1;
	public static inline var BRANCH_DEATH_TIME = 1;
	public static inline var DISAPPEAR_TIME = 1;
	public static inline var TIME_TO_FALL = 4;

	public var organID: OrganID;

	public var parentPlant:Plant;
	public var parentBranch:Branch;
	public var GenerationIndex:Int;
	public var maxLength:Float;
	public var thickness:Float;
	public var energy:Float;
	public var energyDensity:Float;
	public var dir:Vec2;
	public var dirLeaned:Vec2;
	public var length:Float;
	public var widthStart:Float;
	public var widthEnd:Float;
	public var square:Float;
	public var startPos:Vec2;
	public var endPos:Vec2;
	public var posOnBranch:Float;
	public var leanByWind:Float;
	public var dead:Bool;
	public var deathtime:Float;
	public var deathDeltaY:Float;
	public var disapperTime:Float;
	public var totalDeath:Bool;
	public var v1:Vec2;
	public var v2:Vec2;
	public var v3:Vec2;
	public var v4:Vec2;

	var sideVec:Vec2;

	public var MAX_ENERGY_DENSITY(get, null): Float;

	public function new() {
		dir = new Vec2(0, -1);
		dirLeaned = new Vec2(0, -1);
		startPos = new Vec2(0, 0);
		endPos = new Vec2(0, -1);

		v1 = new Vec2(0, 0);
		v2 = new Vec2(0, 0);
		v3 = new Vec2(0, 0);
		v4 = new Vec2(0, 0);
		sideVec = new Vec2();

		Init();
	}

	public function Init() {
		organID = leaveID;
		energy = 1;
		square = 1;
		energyDensity = 0;
		parentBranch = null;
		GenerationIndex = 0;
		maxLength = 20;
		thickness = 1;
		length = 1;
		widthStart = 1;
		widthEnd = 1;
		leanByWind = 0;
		posOnBranch = 1;
		dead = false;
		deathtime = 0;
		deathDeltaY = 0;
		disapperTime = 0;
		totalDeath = false;

		dir.set(0, -1);
		dirLeaned.set(0, -1);
		startPos.set(0, 0);
		endPos.set(0, -1);
	}

	public function get_MAX_ENERGY_DENSITY(): Float {
		switch (organID) {
			case leaveID: return DNA.MAX_LEAF_ENERGY_DENSITY;
			case seedID: return DNA.MAX_SEED_ENERGY_DENSITY;
			case branchID: return DNA.MAX_BRANCH_ENERGY_DENSITY;
		}
		return DNA.MAX_BRANCH_ENERGY_DENSITY;
	} ;

	public function AddEnergy(energyPiece:Float):Float {
		if (parentBranch != null) {
			if (parentBranch.dead) {
				return 0;
			}
			if (parentBranch.parentBranch != null && parentBranch.parentBranch.dead) {
				return 0;
			}
		}

		var energyChange:Float = 0;
		energy += energyPiece;

		if (square > 1) {
			energyDensity = energy / square;
			if (energyDensity > MAX_ENERGY_DENSITY) {
				energyChange = energyPiece - (energy - MAX_ENERGY_DENSITY * square);
				energy = MAX_ENERGY_DENSITY * square;
				return -energyChange;
			}
		}
		return energyPiece;
	}

	public function UpdateDensity() {
		square = (widthEnd + widthStart) * 0.5 * length;

		if (square > 1) {
			energyDensity = energy / square;
		} else {
			energyDensity = 0;
		}
		if (energyDensity > MAX_ENERGY_DENSITY) {
			energyDensity = MAX_ENERGY_DENSITY;
			energy = energyDensity * square;
		}
	}

	public function ConsumeEnergy() {
		energy -= DNA.LEAF_ENERGY_CONSUME * square * FPS.dt;

		if (energy < 0) {
			dead = true;
			if (parentBranch != null) {
				parentBranch.LeavesIndices.remove(this);
			}
		}
	}

	public function ExchangeEnergyWithParent() {
		var delta:Float = 0;
		if (parentBranch.dead) {
			energy -= 2 * square * FPS.dt;
			return;
		}

		if (length < maxLength) {
			if (parentBranch.energyDensity > energyDensity) // && parentBranch.energyDensity>BRANCH_ENERGY_TO_SHARE)
			{
				delta = FPS.dt * DNA.BRANCH_ENERGY_2_LEAF * parentBranch.energy;
				delta = AddEnergy(delta);
				// energy += delta;
				parentBranch.energy -= delta;
			}
		} else {
			if (energyDensity > DNA.LEAF_ENERGY_TO_SHARE) {
				delta = FPS.dt * DNA.LEAF_ENERGY_2_BRANCH * energy;
				delta = parentBranch.AddEnergy(delta);
				// parentBranch.energy += delta;
				energy -= delta;
			}
		}
		UpdateDensity();
	}

	public function CalculateGrowth(dt:Float) {
		if (energy < 0) {
			return;
		}

		if (length >= maxLength) {
			return;
		}

		var delta:Float = DNA.LEAF_GROWTH_RATE * energy * dt;
		if (delta > energy)
			delta = energy;
		length += Math.sqrt(delta);
		energy -= delta;
	}

	public function CalculateDeath():Void {
		deathtime += FPS.dt;
		if (deathtime > LEAF_DEATH_TIME) {
			totalDeath = true;
			return;
		}

		startPos.y += deathtime * 5;

		if (startPos.y > 0) {
			startPos.y = 0;
		}
		CalculateVertices();
	}

	public function CalculateVertices():Void {
		if (!dead) {
			var len:Float = posOnBranch * parentBranch.maxLength;
			if (parentBranch.length < len) {
				len = parentBranch.length;
			}
			startPos.setFrom(parentBranch.startPos.add(parentBranch.dir.mult(len)));
		}

		endPos.setFrom(dir);
		endPos = startPos.add(endPos.mult(length));

		widthStart = 0;
		widthEnd = length * thickness * 0.5;

		sideVec.setFrom(dir.skew().mult(widthStart));

		v1.set(startPos.x - sideVec.x, startPos.y - sideVec.y);
		v4.set(startPos.x + sideVec.x, startPos.y + sideVec.y);

		sideVec.setFrom(dir.skew().mult(widthEnd));
		v2.set(endPos.x - sideVec.x, endPos.y - sideVec.y);
		v3.set(endPos.x + sideVec.x, endPos.y + sideVec.y);

		UpdateDensity();
	}

	public function Calculate(dt:Float):Void {
		if (totalDeath) {
			return;
		}

		CalculateGrowth(dt);
		ExchangeEnergyWithParent();
		ConsumeEnergy();

		CalculateVertices();

		Ecosystem.sunlight.CheckCollisionWithLeaf(this);
	}

	public function Draw(framebuffer:Framebuffer):Void {
		var a:Float = 1 - deathtime / LEAF_DEATH_TIME;
		if (a < 0)
			a = 0;

		var g2 = framebuffer.g2;
		var c:Float = energyDensity / MAX_ENERGY_DENSITY;
		var r:Float = 0;
		if (c < 0)
			c = 0;
		if (c > 1)
			c = 1;

		if (totalDeath)
			g2.color = kha.Color.fromFloats(0, 0, 1, 1);
		else
			g2.color = kha.Color.fromFloats(0, c, 0, a);
		//	if (dead) g2.color = kha.Color.fromFloats(0.1, 0.1, 0, 1);

		g2.fillTriangle(v2.x, v2.y, v3.x, v3.y, v4.x, v4.y);
	}

	public function DrawSkeleton(framebuffer:Framebuffer):Void {
		var g2 = framebuffer.g2;
		g2.color = kha.Color.Green;
		g2.drawLine(startPos.x, startPos.y, endPos.x, endPos.y, 2);
		g2.drawLine(v1.x, v1.y, v4.x, v4.y, 2);
		g2.color = kha.Color.Red;
		g2.drawLine(v2.x, v2.y, v3.x, v3.y, 2);
	}
}
