
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
	public static inline var DEATH_TIME_TO_DISAPPEAR = 3;
	public var ChildrenIndices : Array<Branch>;
	public var LeavesIndices : Array<Leaf>;

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

	}


	public override function ExchangeEnergyWithBranch(b: Branch, energyPiece:Float)
	{
		if (energy<0) return;
		var delta: Float = energyPiece;
		if (energy < energyPiece) delta=energy; 
		b.energy += delta;
		energy -= delta;
	}

	public function GiveEnergyToLeaf(l: Leaf, energyPiece:Float)
	{
		if (energy<0) return;
		//if (l.length >= l.maxLength) return;
		var delta: Float = energyPiece;
		if (energy < energyPiece) delta=energy; 
		l.energy += delta;
		//if (l.energy>Plant.MAX_ENERGY_IN_LEAF) l.energy = Plant.MAX_ENERGY_IN_LEAF;
		energy -= delta;
	}

/*	public function CalculateGrowth(dt: Float)
	{
		if (energy<0) return;
		if (length > maxLength) return;

        var delta: Float  =  energy *dt;
		if (delta>energy) delta = energy;

		length +=  Math.sqrt(delta);  
		widthStart= length*Thikness;
		widthEnd=0;

		energy -=  delta; 
	}*/

	public function ChangeEnergy(plant:Plant, energyPiece: Float):Float
	{
		var energyChange: Float =0 ;
		energy +=energyPiece;
		if (energy>Plant.MAX_ENERGY_IN_BRANCH) {
			
			energyChange = energyPiece - (energy - Plant.MAX_ENERGY_IN_BRANCH) ;
			energy = Plant.MAX_ENERGY_IN_BRANCH;
			return energyChange;
		}
		if (energy < 0) {
			
			energyChange = - energy ;
			energy = 0;
			return energyChange;
		}
		return energyPiece;
	}

	public override function ConsumeEnergy(dt: Float)
	{

//		energy -= Plant.BRANCH_ENERGY_CONSUME * square * dt;

		if (energy<0 ) return;

		if (parentBranch != null)		
        {
            if (parentBranch.dead) 
			{
				energy -= square * dt;
			}
        }

		energy -= Plant.BRANCH_ENERGY_CONSUME * square * dt;
		
		if (energy < 0) 
		{
			dead = true;
		}

	}

	public function CalculateEnergy(dt: Float)
	{
		if (energy<=0) return;

		var delta: Float;
		delta  =  energy * dt;

		ConsumeEnergy(dt);

		if (length< maxLength*0.1) return;

         if (energyDensity< Plant.BRANCH_ENERGY_TO_SHARE) return;

        if (parentBranch != null)
        {
            ExchangeEnergyWithBranch(parentBranch, Plant.BRANCH_ENERGY_2_BRANCH * delta);
        }

                    
        for (b in ChildrenIndices)
        {
          	ExchangeEnergyWithBranch(b, Plant.BRANCH_ENERGY_2_BRANCH * delta  );
		}


        for (l in LeavesIndices)
        {
            GiveEnergyToLeaf(l,  Plant.BRANCH_ENERGY_2_LEAF * delta);
        } 		
	}


	public override function  Calculate ( dt: Float): Void {
		if (dead)
		{
			deathtime += dt;
			if (deathtime> Branch.DEATH_TIME_TO_DISAPPEAR) {
				totalDeath = true;
				return;
			}
			startPos.y += deathtime *10;
			if (startPos.y > System.windowHeight()) startPos.y = System.windowHeight();
		}
		else if (parentBranch != null)
		{
			startPos.setFrom(parentBranch.endPos);
		}


		//endPos.setFrom(dir);
		endPos.setFrom( startPos.add( dir.mult(length)) );

		
		if (ChildrenIndices.length >0)
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
			widthStart = length* Thikness + widthEnd;
		}

		var sideVec: Vec2;
		// start points
		if (parentBranch!= null && !dead)
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
		if (square>0)
		{
			energyDensity = energy / square;
		}

		
	}
	
	public override function Draw (framebuffer:Framebuffer): Void 
	{
		if (deathtime> DEATH_TIME_TO_DISAPPEAR) return;

		var g2 = framebuffer.g2;
		var c: Float = energyDensity / Plant.MAX_ENERGY_IN_BRANCH;
		if (c<0) c= 0;
		if (c>1) c =1;
		g2.color = kha.Color.fromFloats(0.8*c, 0.4*c, 0, 1);
		if (dead) g2.color = kha.Color.fromFloats(0, 0, 0, 1);

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

