
//-------------------------------------------------------
// class of branch
//-------------------------------------------------------


package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;

class Branch
{
	public var parentIndex: Int;
	public var GenerationIndex: Int;
	public var maxGenerations: Int;
	public var timeToNewBranch: Float;
	public var dir: Vec2;
	public var lenght: Float;
	public var growthRate: Float;

	public var startPos : Vec2;
	public var endPos : Vec2;
	public var Thikness : Float;


	public function new() 
    {
		parentIndex = -1;
		GenerationIndex = 0;
		maxGenerations = 1;
		timeToNewBranch = 0;
		dir = new Vec2(0,-1);
		lenght = 10;
		startPos = new Vec2(0,0);
		endPos = new Vec2(0,100);
		Thikness= 0.2;
		growthRate = 0.1;
	}

	public function Calculate (dt: Float): Void {
		endPos.setFrom(dir);
		endPos =startPos.add( endPos.mult(lenght));
	
	}
	
	public function Draw (framebuffer:Framebuffer): Void 
	{
		var g2 = framebuffer.g2;
		var sideVec: Vec2 = new Vec2();
		sideVec = dir.skew().mult(lenght*Thikness*0.5);
		
		
		if (timeToNewBranch <0 ) 
		{ 
			g2.color = kha.Color.fromString("#FFAA5500");
        	g2.fillTriangle( startPos.x - sideVec.x, startPos.y - sideVec.y, 
				endPos.x, endPos.y, 
				startPos.x + sideVec.x, startPos.y + sideVec.y );
		}
		else 
		{
			g2.color = kha.Color.fromFloats(GenerationIndex/maxGenerations,0.7,GenerationIndex/maxGenerations,1);
			sideVec.mult(2);
        	g2.fillTriangle( endPos.x - sideVec.x, endPos.y - sideVec.y, 
				startPos.x, startPos.y, 
				endPos.x + sideVec.x, endPos.y + sideVec.y );
		}
	}

}