

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
	public var parentIndex: Int;
	public var GenerationIndex: Int;
	public var maxLength: Float;

	public var energy: Float;

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
		maxLength = 20;

		energy = 1;

		dir = new Vec2(0,-1);
		length = 1;
		widthStart = 1;
		widthEnd = 1;
		startPos = new Vec2(0,0);
		endPos = new Vec2(0,100);
		Thikness= 0.5;

		NewBranchLength = 40;

		v1= new Vec2(0,0);
		v2= new Vec2(0,0);
		v3= new Vec2(0,0);
		v4= new Vec2(0,0);
	}



	public function Calculate (plant:Plant, dt: Float): Void {

		startPos = plant.branches[parentIndex].endPos;
		endPos.setFrom(dir);
		endPos =startPos.add( endPos.mult(length));

		widthStart= 0;
		widthEnd= length*Thikness;

		var sideVec: Vec2 = new Vec2(0,0);
		sideVec = dir.skew().mult(widthStart);

		v1.set(startPos.x - sideVec.x, startPos.y - sideVec.y);
		v4.set(startPos.x + sideVec.x, startPos.y + sideVec.y);

		sideVec = dir.skew().mult(widthEnd);
		v2.set( endPos.x -  sideVec.x, endPos.y - sideVec.y ); 
		v3.set(endPos.x + sideVec.x, endPos.y + sideVec.y);

		
	}
	
	public function Draw (framebuffer:Framebuffer): Void 
	{
		var g2 = framebuffer.g2;
		g2.color = kha.Color.Red;

		g2.fillTriangle(v1.x,v1.y, v2.x,v2.y, v4.x,v4.y);
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

