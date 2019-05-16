import Utils.Vec2;
import kha.Framebuffer;
import kha.System;

using kha.graphics2.GraphicsExtension;

//-------------------------------------------------------
// class of seed
//-------------------------------------------------------
class Seed extends Leaf {
	var newDNA:DNA;
	var conservatedEnergy:Float;
	var seedEnergyDensity: Float;

	public function new(plant:Plant) {
		super(plant);
	}

	public override function Init() {
		super.Init();
		conservatedEnergy = 0;
		seedEnergyDensity = 0;
		newDNA = parentPlant.dna.duplicate();
	}

	public override function ExchangeEnergyWithParent() {
		var delta:Float = 0;
		if (parentBranch.dead) {
			energy -= 2 * square * FPS.dt;
			return;
		}

		if (parentBranch.energyDensity > energyDensity &&// && parentBranch.energyDensity>BRANCH_ENERGY_TO_SHARE)
		 ( seedEnergyDensity < DNA.MAX_CONSERVATED_ENERGY) )
		{
			delta = FPS.dt * DNA.BRANCH_ENERGY_2_SEED * parentBranch.energy;
			energy += delta;
			parentBranch.energy -= delta;
		} 

		UpdateDensity();
	}


	public  function ConservateEnergy() {

		seedEnergyDensity = conservatedEnergy/square;
		if (seedEnergyDensity >= DNA.MAX_CONSERVATED_ENERGY) {
			dead = true;
			return;
		}

		var delta: Float = DNA.SEED_ENERGY_2_CONSERVATE * square * FPS.dt;
		energy -= delta;
		conservatedEnergy += delta;

		
	}

	public override function ConsumeEnergy(dt:Float) {
		
		ConservateEnergy();

		energy -= DNA.SEED_ENERGY_CONSUME * square * dt;
		UpdateDensity();

		if (energy < 0) {
			dead = true;
		}
	}

	public override function CalculateDeath(dt:Float):Void {
		deathtime += dt;

		startPos.y += deathtime * 5;

		if (startPos.y > 0) {
			startPos.y = 0;
			Ecosystem.AddNewPlant(startPos, newDNA, conservatedEnergy);
			if (parentBranch != null) {
				parentBranch.SeedsIndices.remove(this);
			}
			totalDeath = true;

		}
	}

	
	public override function Draw(framebuffer:Framebuffer):Void {

//		if (deathtime > Leaf.DEATH_TIME)	return;

		var a:Float = 1 - disapperTime / Leaf.DISAPPEAR_TIME;
		if (a < 0)
			a = 0;

		var g2 = framebuffer.g2;
		var c:Float = seedEnergyDensity / DNA.MAX_CONSERVATED_ENERGY;
		var r:Float = 0;
		if (c < 0)
			c = 0;
		if (c > 1)
			c = 1;

		g2.color = kha.Color.fromFloats(c, 0, 0, a);
		//	if (dead) g2.color = kha.Color.fromFloats(0.1, 0.1, 0, 1);

		g2.fillTriangle(v2.x, v2.y, v3.x, v3.y, v4.x, v4.y);
	}
}
