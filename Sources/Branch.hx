
//-------------------------------------------------------
// class of branch
//-------------------------------------------------------


package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Plant;

class Branch  extends  Leaf
{

	public var ChildrenIndices : Array<Branch>;
	public var LeavesIndices : Array<Leaf>;
	var naked : Bool ;
	var length0: Float;

	public function new(plant: Plant) 
    {
		ChildrenIndices = [];
		LeavesIndices = [];
		super(plant);
	}

	public override function Init()
	{
		super.Init();
	
		ChildrenIndices.splice(0, ChildrenIndices.length);
		LeavesIndices.splice(0, LeavesIndices.length);

		 naked  = false;
		 length0 =0;

	}


		
	public override function ExchangeEnergyWithParent()
	{
		if (parentBranch == null) return;

		if (parentBranch.dead) 
		{
			energy -= 4 * square * FPS.dt;
			return;
        }

		var delta:Float = 0;
		
		//if (length< maxLength*0.5) 
		if (parentBranch.energyDensity > energyDensity 
		//	&& length < maxLength
		//	&& !naked
			&& (parentBranch.energyDensity > DNA.BRANCH_ENERGY_TO_SHARE_WITH_CHILD))
		{
			delta = FPS.dt * DNA.BRANCH_ENERGY_2_BRANCH * parentBranch.energy;
			energy += delta;
			parentBranch.energy -= delta;			
		}
		else if (energyDensity > DNA.BRANCH_ENERGY_TO_SHARE_WITH_PARENT)
		// if (parentBranch.energyDensity < energyDensity)
		{
			delta =  FPS.dt * DNA.BRANCH_ENERGY_2_BRANCH * energy;
			energy -= delta;
			parentBranch.energy += delta;			
		}

		UpdateDensity();
	}


	public override function CalculateGrowth(dt: Float)
	{
		if (energy<0) return;
		if (length > maxLength) return;

        var delta: Float  = DNA.BRANCH_GROWTH_RATE * energy *dt;
		if (delta>energy) delta = energy;

		length +=  Math.sqrt(delta);  

		energy -=  delta; 
	}


	public function  CalculateDeath ( dt: Float): Void {
		naked  = true;
		for (c in ChildrenIndices) 
		{
			naked = naked && c.naked;
		}
		if (!naked) return;
		
		deathtime += FPS.dt;
		
		if (deathtime> Leaf.DEATH_TIME) {
			totalDeath = true;
			if (parentBranch!=null) {
				parentBranch.ChildrenIndices.remove(this);
			}
			return;
		}	
		if (deathtime> Leaf.TIME_TO_FALL)
		{
			startPos.y += (deathtime - Leaf.TIME_TO_FALL) *10;
		}
		
		if (startPos.y > 0) {
			disapperTime +=  FPS.dt;
			startPos.y = 0;	
		}

	}


	public override function  CalculatePos ( dt: Float): Void {
		if (dead) CalculateDeath(dt);
		else if (parentBranch != null)
		{
			startPos.setFrom(parentBranch.endPos);
		}

		endPos.setFrom( startPos.add( dir.mult(length)) );



		if (length< maxLength && ChildrenIndices.length == 0) 
		{
			widthStart= length* parentPlant.dna.branch_tickness;
			widthEnd=0;
		} else widthStart = length* parentPlant.dna.branch_tickness + widthEnd;

		if (parentBranch!= null)
		{
			if (parentBranch.widthEnd < widthStart ) 
			{
				parentBranch.widthEnd = widthStart;
			}
		}

		var sideVec: Vec2;
		// start points
		if (parentBranch!= null)// && !dead)
		{
			sideVec = parentBranch.dir.skew().mult(widthStart);
		} 
		else sideVec = dir.skew().mult(widthStart);

		v1.set(startPos.x - sideVec.x, startPos.y - sideVec.y);
		v4.set(startPos.x + sideVec.x, startPos.y + sideVec.y);

		// end points
		sideVec = dir.skew().mult(widthEnd);

		v2.set( endPos.x -  sideVec.x, endPos.y - sideVec.y ); 
		v3.set(endPos.x + sideVec.x, endPos.y + sideVec.y);

		square = (widthEnd + widthStart) *0.5 * length;
		
		UpdateDensity();

		
	}

	public override function  Calculate(dt: Float): Void 
	{
		
		if (totalDeath) return;
		
		CalculatePos(dt);

		for (l in LeavesIndices)
		{
			l.Calculate(dt);
		}
		for (b in ChildrenIndices)
		{
			b.Calculate(dt);
		}

		UpdateDensity();

		if (!dead) {
/*			var numleaves:Float = 1/ parentPlant.dna.leaf_growth_pos;
			var even: Bool = true;
			if (Math.ceil(numleaves)%2 ==1) even = false;
			*/
			var step : Float = maxLength * parentPlant.dna.leaf_growth_pos ;
			//if (even) step = maxLength * parentPlant.dna.leaf_growth_pos ;

			var l1: Float = Math.ceil(length/ step);
			var l0: Float = Math.ceil(length0/ step);
			
            if ( l0 != l1 && (length < maxLength) )
			//(length >  maxLength * parentPlant.dna.leaf_growth_pos ) 
			//&& (LeavesIndices.length == 0) //)
		//	&& energyDensity> DNA.BRANCH_ENERGY_TO_PRODUCE_LEAF)
            {
				var angles: Array<Float>;
				var k: Float = l1 * step / maxLength;
				angles = parentPlant.dna.getLeaves(energyDensity);
				for (a in angles)
				{  
					parentPlant.CreateNewLeaf(this,  a  , k ); 
					//parentPlant.CreateNewLeaf(this, LeavesIndices.length%2==0? a : -a , k ); 
					if (a != 0) parentPlant.CreateNewLeaf(this, -a, k );
				}

            }

			if ((length >= maxLength * parentPlant.dna.branch_growth_pos ) 
			&& (ChildrenIndices.length == 0) //)
			&& energyDensity> DNA.BRANCH_ENERGY_TO_PRODUCE_BRANCH)
            {
				var angles: Array<Float>;
				angles = parentPlant.dna.getBranches(energyDensity);
				for (a in angles)
				{
					parentPlant.CreateNewBranch(this, a ); 
				}

            }
			
			length0 = length;

            CalculateGrowth(dt);
            ExchangeEnergyWithParent();
            ConsumeEnergy(dt);
         }



	}
	
	public override function Draw (framebuffer:Framebuffer): Void 
	{
		if (deathtime> Leaf.DEATH_TIME) return;

		var a: Float = 1 - disapperTime / Leaf.DISAPPEAR_TIME;
		if (a<0) a=0;

		var g2 = framebuffer.g2;
		var c: Float = energyDensity / DNA.MAX_ENERGY_IN_BRANCH;
		if (c<0) c= 0;
		if (c>1) c =1;
		g2.color = kha.Color.fromFloats(0.8*c, 0.4*c, 0, a);
		if (dead) g2.color = kha.Color.fromFloats(0, 0, 0, a);

		g2.fillTriangle(v1.x,v1.y, v2.x,v2.y, v4.x,v4.y);
		g2.fillTriangle(v2.x,v2.y, v3.x,v3.y, v4.x,v4.y);

	}
	
	public override function DrawSkeleton (framebuffer:Framebuffer): Void
	{
		var g2 = framebuffer.g2;
		g2.color = kha.Color.Black;
		g2.drawLine(startPos.x,startPos.y,endPos.x,endPos.y,2);
		g2.drawLine(v1.x,v1.y,v4.x,v4.y,2);
		g2.color = kha.Color.Red;
		g2.drawLine(v2.x,v2.y,v3.x,v3.y,2);
	}

}

