
//-------------------------------------------------------
// class of branch
//-------------------------------------------------------


package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Plant;

class Branch
{
	public static inline var DEATH_TIME_TO_DISAPPEAR = 3;
	public var parentIndex: Int;
	public var GenerationIndex: Int;
	public var maxGenerations: Int;

	public var energy: Float;


	public var weight : Float;
	public var ChildrenIndices : Array<Int>;
	public var LeavesIndices : Array<Int>;

	public var dir: Vec2;
	public var length: Float;
	public var widthStart: Float;
	public var widthEnd: Float;
	public var startPos : Vec2;
	public var endPos : Vec2;
	public var Thikness : Float;
	public var NewBranchLength: Float;
	public var dead: Bool;
	public var deathtime: Float;
	public var totalDeath: Bool;

	var sideVec: Vec2 ;

	public var v1: Vec2;
	public var v2: Vec2;
	public var v3: Vec2;
	public var v4 :Vec2;


	public function new() 
    {
		ChildrenIndices = [];
		LeavesIndices = [];

		dir = new Vec2(0,-1);
		startPos = new Vec2(0,0);
		endPos = new Vec2(0,100);


		v1= new Vec2(0,0);
		v2= new Vec2(0,0);
		v3= new Vec2(0,0);
		v4= new Vec2(0,0);

		sideVec = new Vec2(0,0);

		Init();
	}

	public function Init()
	{
		parentIndex = -1;
		GenerationIndex = 0;
		maxGenerations = 1;

		energy = 1;
		weight =1;
		ChildrenIndices.splice(0, ChildrenIndices.length);
		LeavesIndices.splice(0, LeavesIndices.length);

		dir = new Vec2(0,-1);
		length = 1;
		widthStart = 1;
		widthEnd = 1;
		Thikness= 0.03;

		NewBranchLength = 140;
		dead = false;
		deathtime =0;
		totalDeath = false;

	}


	public function GiveEnergyToBranch(b: Branch, energyPiece:Float)
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
		if (l.length >= l.maxLength) return;
		var delta: Float = energyPiece;
		if (energy < energyPiece) delta=energy; 
		l.energy += delta;
		energy -= delta;
	}

	public function CalculateGrowth(dt: Float)
	{
		if (energy<0) return;
		if (length > NewBranchLength) return;

        var delta: Float  =  energy *dt;
		if (delta>energy) delta = energy;

		length +=  delta ; 
		widthStart= length*Thikness;
		widthEnd=0;

		energy -=  delta; 
	}


	public function ConsumeEnergy(plant:Plant, dt: Float)
	{

		if (energy<0 ) return;

		 if (parentIndex >=0)
        {
            if (plant.branches[parentIndex].dead) 
			{
				energy -= (widthStart + widthEnd) * length * dt;
			}
        }
		
		if (length < NewBranchLength)
		{
			energy -= 0.0001* (widthStart + widthEnd) * length * dt;
		}
		else 	energy -= 0.002* (widthStart + widthEnd) * length * dt;

		if (energy < 0) 
		{
			dead = true;
		}
	}

	public function CalculateEnergy(plant:Plant, dt: Float)
	{
		if (energy<=0) return;

		var delta: Float;
		delta  =  energy * dt;

        if (parentIndex >=0)
        {
            GiveEnergyToBranch(plant.branches[parentIndex], delta);
        }

        if (ChildrenIndices.length>0)
        {
            var i=0;
                    
            for (i in ChildrenIndices)
            {
				var b:Branch = plant.branches[i];
				if (b.length < b.NewBranchLength)
				{
                	GiveEnergyToBranch(b, b.weight * delta *0.5 );
				}; // else  GiveEnergyToBranch(b, b.weight * delta * 0.3 );
			}
		}

	    if (LeavesIndices.length>0)
        {
            var i=0;

            for (i in LeavesIndices)
            {
                GiveEnergyToLeaf(plant.leaves[i],  delta);
            } 
		}  

	    ConsumeEnergy(plant,dt);
		
	}


	public function Calculate (plant:Plant, dt: Float): Void {
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
		else if (parentIndex>=0)
		{
			startPos.setFrom(plant.branches[parentIndex].endPos);
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
				w = plant.branches[ChildrenIndices[c]].widthStart;
				if (wMax < w) 
				{
					wMax =  w;
				}
				c++;
			}
			widthEnd = wMax;
			widthStart = length* Thikness + widthEnd;
		}

		
		

		// start points
		if (parentIndex>=0 && !dead)
		{
			sideVec.setFrom( plant.branches[parentIndex].dir.skew().mult(widthStart));
		} 
		else sideVec.setFrom( dir.skew().mult(widthStart));

		v1.set(startPos.x - sideVec.x, startPos.y - sideVec.y);
		v4.set(startPos.x + sideVec.x, startPos.y + sideVec.y);


		// end points
		sideVec = dir.skew().mult(widthEnd);


		v2.set( endPos.x -  sideVec.x, endPos.y - sideVec.y ); 
		v3.set(endPos.x + sideVec.x, endPos.y + sideVec.y);

		
	}
	
	public function Draw (framebuffer:Framebuffer): Void 
	{
		if (deathtime> DEATH_TIME_TO_DISAPPEAR) return;

		var g2 = framebuffer.g2;
		var c: Float = energy /36;
		if (c<0) c= 0;
		if (c>1) c =1;
		g2.color = kha.Color.fromFloats(0.8*c, 0.4*c, 0, 1);
		if (dead) g2.color = kha.Color.fromFloats(0, 0, 0, 1);

		g2.fillTriangle(v1.x,v1.y, v2.x,v2.y, v4.x,v4.y);
		g2.fillTriangle(v2.x,v2.y, v3.x,v3.y, v4.x,v4.y);

	}
	
	public function DrawSkeleton (framebuffer:Framebuffer): Void
	{
		var g2 = framebuffer.g2;
		g2.color = kha.Color.Black;
		g2.drawLine(startPos.x,startPos.y,endPos.x,endPos.y,2);
		g2.drawLine(v1.x,v1.y,v4.x,v4.y,2);
		g2.color = kha.Color.Red;
		g2.drawLine(v2.x,v2.y,v3.x,v3.y,2);
	}

}

