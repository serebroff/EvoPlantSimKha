package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Plant;
using Leaf;


//------------------------------------- ------------------
// foton class 
//-------------------------------------------------------
class Foton {

        // constants
    public static inline var SPEED = 400;  // pixel / sec
    public static inline var BEAM_LENGTH = 10.0; 

    public var pos: Vec2;
    public var dir: Vec2;

//    public satatic var angle: Float;

    public function new() 
    {  
        pos = new Vec2(System.windowWidth() * Math.random(), System.windowHeight() * Math.random());
        dir = new Vec2(1, 1);
        dir.normalize();
        dir=dir.mult(Math.random() +1);
    }

    public function Calculate(dt:Float): Void {
        pos= pos.add(dir.mult(dt*SPEED));
        if (pos.y>System.windowHeight() || pos.x>System.windowWidth()) Renew();
    }

    public function Renew(): Void {
        if (Math.random()<0.4)  this.pos.set(0, System.windowHeight() * Math.random());
        else this.pos.set(System.windowWidth() * Math.random(), 0);
    }

    public function CheckCollision(plant: Plant)
    {
        var b: Branch;
        var l: Leaf;
        for (l in plant.leaves)
        {
            //if (pos.PointInTriangle(l.v1,l.v2,l.v4) || pos.PointInTriangle(l.v2,l.v3,l.v4))
            if (l.dead) continue;
            if (pos.PointInTriangle(l.v2,l.v3,l.v4))
            {
                l.energy+=6;
                Renew();
            }
        }

/*        for (b in plant.branches)
        {
            if (pos.PointInTriangle(b.v1,b.v2,b.v4) || pos.PointInTriangle(b.v2,b.v3,b.v4))
            {
                b.energy+=1;
                Renew();
            }
        }*/
    }


	public function Draw(framebuffer: Framebuffer): Void {
		var g2 = framebuffer.g2;

		g2.color = kha.Color.Orange; //fromFloats(0.2,0.2,0.9, 0.7 );
		
        g2.drawLine (pos.x, pos.y , pos.x + dir.x*BEAM_LENGTH, pos.y + dir.y*BEAM_LENGTH, 2);
		//g2.fillCircle( pos.x, pos.y, 2);

	}

}




