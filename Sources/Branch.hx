//-------------------------------------------------------
// class of branch
//-------------------------------------------------------
package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Plant;


class Branch extends Leaf {
	public var ChildrenIndices:Array<Branch>;
	public var LeavesIndices:Array<Leaf>;
	public var SeedsIndices:Array<Seed>;


	var readyToFall:Bool;
	var length0:Float;
	var hasProducedSeeds:Bool;
	public var leaves_number: Float;
	public var branch_growth_pos: Float;
	public var generation2blossom: Float;

	public function new() {
		ChildrenIndices = [];
		SeedsIndices = [];
		LeavesIndices = [];
		super();
	}

	public override function Init() {
		super.Init();

		organID = branchID;

		ChildrenIndices.splice(0, ChildrenIndices.length);
		SeedsIndices.splice(0, SeedsIndices.length);
		LeavesIndices.splice(0, LeavesIndices.length);

		readyToFall = false;
		length0 = 0;
		hasProducedSeeds = false;

		branch_growth_pos = 1;
	    leaves_number = 1;
	    generation2blossom =2;
	}

	public override function ConsumeEnergy() {
		energy -= DNA.BRANCH_ENERGY_CONSUME * square * FPS.dt;

		if (energy < 0) {
			dead = true;
		}
	}

	public override function ExchangeEnergyWithParent() {
		var delta:Float = 0;

		if (parentBranch == null) {
			return;
		}

		if (parentBranch.dead) {
			energy -= 4 * square * FPS.dt;
			return;
		}

		// if (length< maxLength*0.5)
		if (parentBranch.energyDensity > energyDensity //	&& length < maxLength
				//	&& !readyToFall
			&& (parentBranch.energyDensity > DNA.BRANCH_ENERGY_TO_SHARE_WITH_CHILD)) {
			delta = FPS.dt * DNA.BRANCH_ENERGY_2_BRANCH * parentBranch.energy;
			//delta = AddEnergy(delta);
			energy += delta;
			parentBranch.energy -= delta;
		} else if (energyDensity > DNA.BRANCH_ENERGY_TO_SHARE_WITH_PARENT)
			// if (parentBranch.energyDensity < energyDensity)
		{
			delta = FPS.dt * DNA.BRANCH_ENERGY_2_BRANCH * energy;
			parentBranch.energy += delta;
//			delta = parentBranch.AddEnergy(delta);
			energy -= delta;
			

		}

		UpdateDensity();
	}

	public override function CalculateGrowth(dt:Float) {
		if (energy < 0)
			return;
		if (length > maxLength)
			return;

		var delta:Float = DNA.BRANCH_GROWTH_RATE * energy * dt;
		if (delta > energy)
			delta = energy;

		length += Math.sqrt(delta);

		energy -= delta;
	}

	public override function CalculateDeath():Void {
		readyToFall = true;

		if (deathtime == 0) {
			for (c in ChildrenIndices) {
				readyToFall = readyToFall && c.readyToFall;
			}

			if (LeavesIndices.length != 0 || SeedsIndices.length != 0) {
				readyToFall = false;
			}
		}

		if (readyToFall) {
			/*if (deathtime == 0)
			{
				if (parentBranch != null) {
					parentBranch.ChildrenIndices.remove(this);
				}
			}*/
			deathtime += FPS.dt;

			if (deathtime > Leaf.TIME_TO_FALL) {
				disapperTime += FPS.dt;
				startPos.y += (deathtime - Leaf.TIME_TO_FALL) * 10;
			}

			if (disapperTime > Leaf.BRANCH_DEATH_TIME) {
				totalDeath = true;
				if (parentBranch != null) {
					parentBranch.ChildrenIndices.remove(this);
				}
			}

			if (startPos.y > 0) {
				startPos.y = 0;
			}
		}

		CalculateVertices();
	}

	public override function CalculateVertices():Void {
		if (!dead && parentBranch != null) {
			startPos.setFrom(parentBranch.endPos);
			//dir.setFrom(parentBranch.dir.rotate(angle));
		}

/*		//if (ChildrenIndices.length==0) {
			leanByWind += Ecosystem.wind.windpower_x * square /300;
		//}
		if (parentBranch!=null)
		{
			leanByWind +=parentBranch.leanByWind;
		} */
		dirLeaned.setFrom(dir);
	//	dirLeaned.x +=leanByWind;
	//	dirLeaned.normalize();

		endPos.setFrom(startPos.add(dirLeaned.mult(length)));

		if (length < maxLength && ChildrenIndices.length == 0) {
			widthStart = length * thickness;
			widthEnd = 0;
		} else {
			widthStart = length * thickness + widthEnd;
		}

		if (parentBranch != null && parentBranch.widthEnd < widthStart) {
			parentBranch.widthEnd = widthStart;
		}

		// start points
		if (parentBranch != null) // && !dead)
		{
			sideVec.setFrom(parentBranch.dirLeaned.skew().mult(widthStart));
		} else
			sideVec.setFrom( dirLeaned.skew().mult(widthStart));

		v1.set(startPos.x - sideVec.x, startPos.y - sideVec.y);
		v4.set(startPos.x + sideVec.x, startPos.y + sideVec.y);

		// end points
		sideVec.setFrom(dir.skew().mult(widthEnd));

		v2.set(endPos.x - sideVec.x, endPos.y - sideVec.y);
		v3.set(endPos.x + sideVec.x, endPos.y + sideVec.y);

		square = (widthEnd + widthStart) * 0.5 * length;

		UpdateDensity();
	}

	public function AddNewLeaves():Void {
		var numleaves:Int = Math.ceil(leaves_number);
		var even:Bool = true;
		if (Math.ceil(numleaves) % 2 == 1) {
			even = false;
		}

		var step:Float = maxLength / numleaves;

		if (even) {
			step *= 2;
		}

		var l1:Float = Math.ceil(length / step);
		var l0:Float = Math.ceil(length0 / step);

		if (l0 != l1 && (length < maxLength))
			// && (LeavesIndices.length == 0) //)
			//	&& energyDensity> DNA.BRANCH_ENERGY_TO_PRODUCE_LEAF)
		{
			var angles:Array<Float>;
			var k:Float = l1 * step / maxLength;
			angles = parentPlant.dna.getAngles(leaveID,this);
			for (a in angles) {
				if (even) {
					parentPlant.CreateNewLeaf(this, a, k);
					if (a != 0)
						parentPlant.CreateNewLeaf(this, -a, k);
				} else {
					parentPlant.CreateNewLeaf(this, (Math.floor(LeavesIndices.length / angles.length) % 2 == 0 ? a : -a) * (GenerationIndex % 2 == 0 ? -1 : 1),
						k);
				}
			}
		}

		length0 = length;
	}

	public function AddNewSeeds():Void {
		if ((length >= maxLength * branch_growth_pos) &&
			(ChildrenIndices.length == 0) // )
			&&
			!hasProducedSeeds &&
			energyDensity > DNA.BRANCH_ENERGY_TO_PRODUCE_BRANCH &&
			(GenerationIndex >= generation2blossom)) {
			var angles:Array<Float>;
			angles = parentPlant.dna.getAngles(seedID, this);

			//for (a in angles) {
				parentPlant.CreateNewSeed(this, angles[0]);
			//}
			hasProducedSeeds = true;
		}
	}

	public function AddNewBranches():Void {
		if ((length >= maxLength * branch_growth_pos) &&
			(ChildrenIndices.length == 0) &&
			(SeedsIndices.length == 0) &&
			energyDensity > DNA.BRANCH_ENERGY_TO_PRODUCE_BRANCH &&
			(hasProducedSeeds || GenerationIndex < generation2blossom))  {
			 
			var angles:Array<Float>;
			angles = parentPlant.dna.getAngles(branchID, this);

			for (a in angles) {
				parentPlant.CreateNewBranch(this, GenerationIndex%2 == 0? a: -a);
			}
		}
	}

	public override function Calculate(dt:Float):Void {
		if (totalDeath) {
			return;
		}

		if (!dead) {
			AddNewLeaves();
			AddNewSeeds();
			AddNewBranches();

			CalculateGrowth(dt);
			ExchangeEnergyWithParent();
			ConsumeEnergy();
		}

		UpdateDensity();

		leanByWind = 0;

		for (l in LeavesIndices) {
			if (!l.dead) {
				l.Calculate(dt);
			}
		}
		for (s in SeedsIndices) {
			if (!s.dead) {
				s.Calculate(dt);
			}
		}
		for (b in ChildrenIndices) {
			b.Calculate(dt);
		}

		// CalculateVertices();
		// UpdateDensity();

		if (dead && !readyToFall) {
			CalculateDeath();
		} else {
			CalculateVertices();
		}
	}

	public override function Draw(framebuffer:Framebuffer):Void {
		var a:Float = 1 - disapperTime / Leaf.BRANCH_DEATH_TIME;
		if (a < 0) {
			a = 0;
		}

		var g2 = framebuffer.g2;
		var c:Float = energyDensity / MAX_ENERGY_DENSITY;

		if (c < 0) {
			c = 0;
		}
		if (c > 1) {
			c = 1;
		}

		g2.color = kha.Color.fromFloats(0.8 * c, 0.4 * c, 0, a);

		if (dead) {
			g2.color = kha.Color.fromFloats(0, 0, 0, a);
		}

		if (length < maxLength) {
			g2.color = kha.Color.fromFloats(0, 0.2 + 0.8 * c, 0, a);
		}

		g2.fillTriangle(v1.x, v1.y, v2.x, v2.y, v4.x, v4.y);
		g2.fillTriangle(v2.x, v2.y, v3.x, v3.y, v4.x, v4.y);
	}

	public override function DrawSkeleton(framebuffer:Framebuffer):Void {
		var g2 = framebuffer.g2;
		g2.color = kha.Color.Black;
		g2.drawLine(startPos.x, startPos.y, endPos.x, endPos.y, 2);
		g2.drawLine(v1.x, v1.y, v4.x, v4.y, 2);
		g2.color = kha.Color.Red;
		g2.drawLine(v2.x, v2.y, v3.x, v3.y, 2);
	}
}
