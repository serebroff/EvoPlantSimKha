
//-------------------------------------------------------
// class of branch
//-------------------------------------------------------


package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Creature;

class Branch
{
	public var parentIndex: Int;
	public var GenerationIndex: Int;
	public var maxGenerations: Int;
	public var timeToNewBranch: Float;


	public var growthRate: Float;
	public var energy: Float;


	public var weight : Float;
	public var ChildrenIndices : Array<Int>;

	public var dir: Vec2;
	public var length: Float;
	public var widthStart: Float;
	public var widthEnd: Float;
	public var startPos : Vec2;
	public var endPos : Vec2;
	public var Thikness : Float;
	public var NewBranchLength: Float;

	public var v1: Vec2;
	public var v2: Vec2;
	public var v3: Vec2;
	public var v4 :Vec2;


	public function new() 
    {
		parentIndex = -1;
		GenerationIndex = 0;
		maxGenerations = 1;
		timeToNewBranch = 0;

		growthRate = 10;
		energy = 1;
		weight =1;
		ChildrenIndices = [];

		dir = new Vec2(0,-1);
		length = 0;
		widthStart = 0;
		widthEnd = 0;
		startPos = new Vec2(0,0);
		endPos = new Vec2(0,100);
		Thikness= 0.05;

		NewBranchLength = 40;

		v1= new Vec2(0,0);
		v2= new Vec2(0,0);
		v3= new Vec2(0,0);
		v4= new Vec2(0,0);
	}


	public function CalcEnd()
	{
		var sideVec: Vec2 = new Vec2(0,0);
		sideVec = dir.skew().mult(widthEnd);
		//v2 = v2.sub(sideVec);
		//v3 = v3.add(sideVec)	;
		v2.set( endPos.x -  sideVec.x, endPos.y - sideVec.y ); 
		v3.set(endPos.x + sideVec.x, endPos.y + sideVec.y);
	}


	public function Calculate (plant:Creature, dt: Float): Void {

		endPos.setFrom(dir);
		endPos =startPos.add( endPos.mult(length));

		widthStart= length*Thikness;
		widthEnd=0;

		var sideVec: Vec2 = new Vec2(0,0);
		sideVec = dir.skew().mult(widthStart);

		if (parentIndex>=0)
		{
			var ParentBanch= plant.branches[parentIndex];
			if (ParentBanch.widthEnd<widthStart)  {
				ParentBanch.widthEnd= widthStart;
				ParentBanch.CalcEnd();
			}
		}


		v1.set(startPos.x - sideVec.x, startPos.y - sideVec.y);
		v2.set( endPos.x , endPos.y ); 
		v3.set(endPos.x , endPos.y  );
		v4.set(startPos.x + sideVec.x, startPos.y + sideVec.y);
		
	}
	
	public function Draw (framebuffer:Framebuffer): Void 
	{
		var g2 = framebuffer.g2;
		var f: Float =  (1 - GenerationIndex / maxGenerations) *0.7 ;
		g2.color = kha.Color.fromFloats(f, 0.7, 0,1);

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

