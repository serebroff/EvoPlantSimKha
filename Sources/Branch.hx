
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
		if (parentBranch.energyDensity > energyDensity && (parentBranch.energyDensity > Plant.BRANCH_ENERGY_TO_SHARE))
		{
			delta = FPS.dt * Plant.BRANCH_ENERGY_2_BRANCH * parentBranch.energy;
			energy += delta;
			parentBranch.energy -= delta;			
		}
		else if (energyDensity > Plant.BRANCH_ENERGY_TO_SHARE)
		// if (parentBranch.energyDensity < energyDensity)
		{
			delta =  FPS.dt * Plant.BRANCH_ENERGY_2_BRANCH * energy;
			energy -= delta;
			parentBranch.energy += delta;			
		}
	}


	public override function CalculateGrowth(dt: Float)
	{
		if (energy<0) return;
		if (length > maxLength) return;

        var delta: Float  =  energy *dt;
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
		
		deathtime += dt;
		
		if (deathtime> Leaf.DEATH_TIME) {
			totalDeath = true;
			return;
		}	

		startPos.y += deathtime *10;
		
		if (startPos.y > System.windowHeight()) {
			disapperTime += dt;
			startPos.y = System.windowHeight();	
		}

	}


	public override function  CalculatePos ( dt: Float): Void {
		if (dead) CalculateDeath(dt);
		else if (parentBranch != null)
		{
			startPos.setFrom(parentBranch.endPos);
		}

		endPos.setFrom( startPos.add( dir.mult(length)) );

		
/*		if (ChildrenIndices.length >0)
		{
			var wMax: Float=0;
			var w: Float =0;
			var c: Int = 0;
			while (c <ChildrenIndices.length)
			{
				w = ChildrenIndices[c].widthStart;
				if (wMax < w) 
				{
					wMax =  w;
				}
				c++;
			}
			widthEnd = wMax;
			widthStart = length* parentPlant.dna.branch_tickness + widthEnd;
		} 
		else {
			widthStart= length* parentPlant.dna.branch_tickness;
			widthEnd=0;
		}
*/
		

		if (length< maxLength) 
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
		if (square>1)
		{
			energyDensity = energy / square;
		} else energyDensity =0;

		
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

		if (!dead) {

            if ((length > maxLength * 0.1 ) && (LeavesIndices.length < 2))
            {
                if (energyDensity> Plant.BRANCH_ENERGY_TO_PRODUCE_LEAF)  
                {
                
                    parentPlant.CreateNewLeaf(this, parentPlant.dna.angle ); //*Utils.rndsign()); // (-1 + 2* Math.random()));
                    parentPlant.CreateNewLeaf(this, -parentPlant.dna.angle );
                   // CreateNewLeaf(b, 0 );
                }
            }
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
		var c: Float = energyDensity / Plant.MAX_ENERGY_IN_BRANCH;
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

