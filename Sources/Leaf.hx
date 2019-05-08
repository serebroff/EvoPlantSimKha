

//-------------------------------------------------------
// class of Leaf
//-------------------------------------------------------


package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Plant;

class Leaf
{
	public static inline var DEATH_TIME = 9;
	public static inline var DISAPPEAR_TIME = 2;
	public static inline var TIME_TO_FALL = 4;

	public var parentPlant: Plant;
	public var parentBranch: Branch;
	public var GenerationIndex: Int;
	public var maxLength: Float;

	public var energy: Float;
	public var energyDensity : Float;

	public var dir: Vec2;
	public var length: Float;
	public var widthStart: Float;
	public var widthEnd: Float;
	public var square: Float;
	public var startPos : Vec2;
	public var endPos : Vec2;
	public var posOnBranch: Float;
	public var dead: Bool;
	public var deathtime: Float;
	public var deathDeltaY: Float;
	public var disapperTime: Float;
	public var totalDeath: Bool;
	public var hasProducedBranch: Bool;

	public var v1: Vec2;
	public var v2: Vec2;
	public var v3: Vec2;
	public var v4 :Vec2;


	public function new(plant:Plant) 
    {
		parentPlant = plant;

		dir = new Vec2(0,-1);
		startPos = new Vec2(0,0);
		endPos = new Vec2(0,100);



		v1= new Vec2(0,0);
		v2= new Vec2(0,0);
		v3= new Vec2(0,0);
		v4= new Vec2(0,0);

		Init();
		
	}

	public function Init()
	{
		energy = 1;
		square = 1;
		energyDensity = 0;
		parentBranch = null;
		GenerationIndex = 0;
		maxLength = 20;
		length = 1;
		widthStart = 1;
		widthEnd = 1;
		posOnBranch = 1;
		dead = false;
		deathtime =0;
		deathDeltaY =0;
		disapperTime =0;
		totalDeath= false;
		hasProducedBranch = false;
	}

	public function AddEnergy(energyPiece: Float):Float
	{
		if (parentBranch.dead) return 0;
		if (parentBranch.parentBranch!=null && parentBranch.parentBranch.dead) return 0;

		var energyChange: Float =0 ;
		energy +=energyPiece;

		if (square>5)
		{
			energyDensity = energy / square;
			if (energyDensity > DNA.MAX_ENERGY_IN_BRANCH) {
			
				energyChange = energyPiece - (energy - DNA.MAX_ENERGY_IN_BRANCH * square) ;
				energy = DNA.MAX_ENERGY_IN_BRANCH * square;
				return -energyChange;
			}
		}
		return energyPiece;
	}


	public function UpdateDensity()
	{
		square = (widthEnd + widthStart) *0.5 * length;

		if (square>1)
		{
			energyDensity = energy / square;
		} 
		else energyDensity =0;
	}

	public function ConsumeEnergy(dt: Float)
	{

		energy -= DNA.LEAF_ENERGY_CONSUME * square * dt;
		if (energyDensity>DNA.MAX_ENERGY_IN_BRANCH)
		{
		//	energy = square * DNA.MAX_ENERGY_IN_BRANCH;
		}
		if (energy < 0) 
		{
			dead = true;
		}
	}


	public function ExchangeEnergyWithParent()
	{
		var delta:Float = 0;
		if (parentBranch.dead) 
		{
			energy -= 2* square * FPS.dt;
			return;
        }

		if (length< maxLength)
		{
			if (parentBranch.energyDensity > energyDensity)// && parentBranch.energyDensity>BRANCH_ENERGY_TO_SHARE)
			{
				delta = FPS.dt * DNA.BRANCH_ENERGY_2_LEAF * parentBranch.energy;
				energy += delta;
				parentBranch.energy -= delta;
			}
		}
		else 
		{
			if (energyDensity > DNA.LEAF_ENERGY_TO_SHARE)
			{
				delta = FPS.dt * DNA.LEAF_ENERGY_2_BRANCH * energy;
				parentBranch.energy += delta;
				energy -= delta;
			}
		}
		UpdateDensity();
	}

	public function CalculateGrowth(dt: Float)
	{
		if (energy<0) return;
		if (length >= maxLength) return;
        var delta: Float  = DNA.LEAF_GROWTH_RATE * energy *dt;
		if (delta>energy) delta = energy;
        length +=  Math.sqrt(delta); 
        energy -=  delta; 
	}

	public function CalculatePos (dt: Float): Void {
		
		if (dead)
		{
			deathtime += dt;
			if (deathtime> DEATH_TIME) {
				totalDeath = true;
				if (parentBranch!=null) {
					parentBranch.LeavesIndices.remove(this);
				}
				return;
			}
			
			startPos.y += deathtime *5;

			if (startPos.y >0) {
				startPos.y = 0;
				disapperTime += dt;
			}
		}
		else {
			var len: Float = posOnBranch * parentBranch.maxLength;
			if (parentBranch.length<  len) len = parentBranch.length;
			startPos.setFrom( parentBranch.startPos.add( parentBranch.dir.mult(len)));
		}


		endPos.setFrom(dir);
		endPos =startPos.add( endPos.mult(length));

		widthStart= 0;
		widthEnd= length * parentPlant.dna.leaf_tickness *0.5;

		var sideVec: Vec2;
		sideVec = dir.skew().mult(widthStart);

		v1.set(startPos.x - sideVec.x, startPos.y - sideVec.y);
		v4.set(startPos.x + sideVec.x, startPos.y + sideVec.y);

		sideVec = dir.skew().mult(widthEnd);
		v2.set( endPos.x -  sideVec.x, endPos.y - sideVec.y ); 
		v3.set(endPos.x + sideVec.x, endPos.y + sideVec.y);

		UpdateDensity();

		
	}

	public function Calculate (dt: Float): Void {
		if (totalDeath) return;
		CalculatePos(dt);
		
        if (!dead) {
/*            if (length> maxLength* parentPlant.dna.leaf_growth_pos && !hasProducedBranch) {
                if (energyDensity> DNA.BRANCH_ENERGY_TO_PRODUCE_BRANCH)  
                {
                    hasProducedBranch = true;
                    //parentPlant.CreateNewBranch(this);
                }
			}*/
            CalculateGrowth(dt);
            ExchangeEnergyWithParent();
            ConsumeEnergy(dt);
        }
	
	}
	
	public function Draw (framebuffer:Framebuffer): Void 
	{
		if (deathtime> DEATH_TIME) return;

		var a: Float = 1 - disapperTime / DISAPPEAR_TIME;
		if (a<0) a=0;

		var g2 = framebuffer.g2;
		var c: Float = energyDensity / DNA.MAX_ENERGY_IN_LEAF;
		var r: Float = 0;
		if (c<0) c= 0;
		if (c>1) c =1;

		g2.color = kha.Color.fromFloats(0, c, 0, a);
	//	if (dead) g2.color = kha.Color.fromFloats(0.1, 0.1, 0, 1);

		g2.fillTriangle(v2.x,v2.y, v3.x,v3.y, v4.x,v4.y);

	}
	
	public function DrawSkeleton (framebuffer:Framebuffer): Void
	{
		var g2 = framebuffer.g2;
		g2.color = kha.Color.Green;
		g2.drawLine(startPos.x,startPos.y,endPos.x,endPos.y,2);
		g2.drawLine(v1.x,v1.y,v4.x,v4.y,2);
		g2.color = kha.Color.Red;
		g2.drawLine(v2.x,v2.y,v3.x,v3.y,2);
	}

}

