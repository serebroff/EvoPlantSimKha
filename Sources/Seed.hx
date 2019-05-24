import Utils.Vec2;
import kha.Framebuffer;
import kha.System;

using kha.graphics2.GraphicsExtension;

//-------------------------------------------------------
// class of seed
//-------------------------------------------------------
class Seed extends Leaf {
	public var newDNA:DNA;
	public var conservatedEnergy:Float;

	var seedEnergyDensity:Float;
	var createdNewPlant:Bool;
	var childFirstBranch:Branch;

	public function new() {
		super();
	}

	public override function Init() {
		super.Init();
		conservatedEnergy = 0;
		seedEnergyDensity = 0;
		createdNewPlant = false;
		childFirstBranch = null;
		newDNA = null;
	}

	public override function ExchangeEnergyWithParent() {
		var delta:Float = 0;
		if (parentBranch.dead) {
			energy -= 2 * square * FPS.dt;
			return;
		}

		if (parentBranch.energyDensity > energyDensity && // && parentBranch.energyDensity>BRANCH_ENERGY_TO_SHARE)
			(seedEnergyDensity < DNA.MAX_CONSERVATED_ENERGY)) {
			delta = FPS.dt * DNA.BRANCH_ENERGY_2_SEED * parentBranch.energy;
			energy += delta;
			parentBranch.energy -= delta;
		}

		UpdateDensity();
	}

	public function ConservateEnergy() {
		seedEnergyDensity = conservatedEnergy / square;
		if (seedEnergyDensity >= DNA.MAX_CONSERVATED_ENERGY) {
			dead = true;
			if (parentBranch != null) {
				parentBranch.SeedsIndices.remove(this);
			}
			return;
		}

		var delta:Float = DNA.SEED_ENERGY_2_CONSERVATE * square * FPS.dt;
		energy -= delta;
		conservatedEnergy += delta;
	}

	public override function ConsumeEnergy() {
		ConservateEnergy();

		energy -= DNA.SEED_ENERGY_CONSUME * square * FPS.dt;
		UpdateDensity();

		if (energy < 0) {
			dead = true;
			if (parentBranch != null) {
				parentBranch.SeedsIndices.remove(this);
			}
		}
	}

	public function ExchangeWithNewPlant():Void {
		if (childFirstBranch.totalDeath) {
			totalDeath = true;
			return;
		}
		var delta: Float;

		delta = conservatedEnergy * FPS.dt;
		conservatedEnergy -= delta;
		childFirstBranch.energy += delta;
		if (conservatedEnergy < 0.1) {
			totalDeath = true;
		}
		return;
	}

	public override function CalculateDeath():Void {
		deathtime += FPS.dt;

		startPos.y += deathtime * 5;

		if (startPos.y + maxLength * 0.5 > 0) {
			startPos.y = maxLength * 0.5;

			if (!createdNewPlant) {
				childFirstBranch = Ecosystem.AddNewPlant(this).firstBranch;
				createdNewPlant = true;
			} else
				ExchangeWithNewPlant();
		}
		CalculateVertices();
	}

	public override function Calculate(dt:Float):Void {
		if (totalDeath) {
			return;
		}

		CalculateGrowth(dt);
		ExchangeEnergyWithParent();
		ConsumeEnergy();

		CalculateVertices();
	}

	public override function Draw(framebuffer:Framebuffer):Void {
		var g2 = framebuffer.g2;
		seedEnergyDensity = conservatedEnergy / square;
		var c:Float = seedEnergyDensity / DNA.MAX_CONSERVATED_ENERGY;

		if (c < 0)
			c = 0;
		if (c > 1)
			c = 1;

		g2.color = kha.Color.fromFloats(c, 0, 0, 1);
		if (createdNewPlant) {
			g2.color = kha.Color.fromFloats(c, 1 - c, 0, Math.sqrt(Math.sqrt(c)));
		}

		g2.fillTriangle(v2.x, v2.y, v3.x, v3.y, v4.x, v4.y);
	}
}
